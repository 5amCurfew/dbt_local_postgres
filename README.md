Open a new terminal in the directory (to activate determined Python version in `.python-version`)

Create the virtual environment by running the following in your terminal when in this directory:

1. `python3 -m venv dbt-env`
2. `source dbt-env/bin/activate`
3. `python3 -m pip install -r requirements.txt`
4. `deactivate`

To use this `venv` run `source dbt-env/bin/activate`. Ensure the dbt environment is being used by running `which dbt`

```bash
Samuels-MacBook-Pro:dbt_local_postgres samuelknight$ source dbt-env/bin/activate
(dbt-env) Samuels-MacBook-Pro:dbt_local_postgres samuelknight$ which dbt
/Users/samuelknight/git/dbt_local_postgres/dbt-env/bin/dbt
```

```bash
(dbt-env) Samuels-MacBook-Pro:dbt_local_postgres samuelknight$ dbt --version
Core:
  - installed: 1.4.5
  - latest:    1.4.5 - Up to date!

Plugins:
  - postgres: 1.4.5 - Up to date!

```

Create a dbt project using `dbt init`

```bash
(dbt-env) Samuels-MacBook-Pro:dbt_local_postgres samuelknight$ dbt init
10:02:17  Running with dbt=1.4.5
Enter a name for your project (letters, digits, underscore): example
Which database would you like to use?
[1] postgres

(Don't see the one you want? https://docs.getdbt.com/docs/available-adapters)

Enter a number: 1
10:02:31  
Your new dbt project "example" was created!

For more information on how to configure the profiles.yml file,
please consult the dbt documentation here:

  https://docs.getdbt.com/docs/configure-your-profile

One more thing:

Need help? Don't hesitate to reach out to us via GitHub issues or on Slack:

  https://community.getdbt.com/

Happy modeling!
```

This example uses a postgres database running in a local docker environment. To recreate this environment:

1. `docker pull postgres`
2. `docker run --name postgres_dev -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=admin -p 5432:5432 -d postgres`, `docker start postgres_dev`

Create a local `example/.dbt/profiles.yml` 

```yml
example:
  outputs:
    dev:
      type: postgres
      host: localhost
      user: admin
      password: admin
      port: 5432
      dbname: postgres
      schema: public
      threads: 1
  target: dev
```

Successful configuration should result in

```bash
(dbt-env) Samuels-MacBook-Pro:dbt_local_postgres samuelknight$ cd example
(dbt-env) Samuels-MacBook-Pro:example samuelknight$ dbt debug --profiles-dir ./.dbt
10:15:50  Running with dbt=1.4.5
dbt version: 1.4.5
python version: 3.11.2
python path: /Users/samuelknight/git/dbt_local_postgres/dbt-env/bin/python3
os info: macOS-12.6.3-x86_64-i386-64bit
Using profiles.yml file at /Users/samuelknight/git/dbt_local_postgres/example/.dbt/profiles.yml
Using dbt_project.yml file at /Users/samuelknight/git/dbt_local_postgres/example/dbt_project.yml

Configuration:
  profiles.yml file [OK found and valid]
  dbt_project.yml file [OK found and valid]

Required dependencies:
 - git [OK found]

Connection:
  host: localhost
  port: 5432
  user: admin
  database: postgres
  schema: public
  search_path: None
  keepalives_idle: 0
  sslmode: None
  Connection test: [OK connection ok]

All checks passed!
```