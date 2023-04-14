
-- Business context:
---     * Planet provides a service where customers select an area and download an image of
--      that area
---     * Based on the size of the area the customer consumes credits
---     * Customers each have a set daily quota of credits which they are able to use, based on their contract

-- Data conext:
--      * The `geo_download` event is recorded when the customer downloads an image through a
--      planet service, this uses credits
--      * The `events` table contains many terrabytes of data and appends 10M+ rows per day
--      * The stakeholder requires the geo_object field, which contains the boundaries for image the organization is downloading. The objects in this field are extremely large and costly to load, so incremental materialization is necessary
--      * Based on the size of the object the organization is charged a given number of 'credits'; these organizations are all on contracts where they have a maximum daily number of credits
--      * The `org_quota` contains one row per organization per day which contains how much quota they were allowed to consume on that day

WITH events AS (

    SELECT 
        event_id, 
        event_timestamp,
        customer_id, 
        credits,
        geo_object
    FROM 
        {{ ref('events')}}
    WHERE 
        event_name = 'geo_download'
    {% if is_incremental() %} 
        AND event_timestamp > ( SELECT max(event_timestamp) FROM {{ this }} )
    {% endif %}

),

quota_details AS (

    SELECT 
        customer_id, 
        quota_date, 
        quota_amount 
    FROM 
        {{ ref('customer_quotas') }}

)

SELECT
    events.customer_id,
    quota_details.quota_date,
    events.event_id, 
    events.event_timestamp,
    event.geo_object,
    SUM(credits) OVER (PARTITION BY events.customer_id, quota_details.quota_date ORDER BY event_timestamp asc ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / quota_details.quota as percent_of_credits
FROM 
    events
    INNER JOIN quota_details ON quota_details.customer_id = c.customer_id AND date_trunc('day', events.event_date) = quota_details.quota_date