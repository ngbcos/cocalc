Recently added collaborators:

    select now()-time,project_id from project_log where time >= now() - interval '1 day' and time <= now() and event#>>'{event}' = 'invite_user' order by time desc;

    select count(*) from project_log where time >= now() - interval '2 day' and time <= now() - interval '1 day' and event#>>'{event}' = 'invite_user';  select count(*) from project_log where time >= now() - interval '1 day' and time <= now() and event#>>'{event}' = 'invite_user';

Exclude course projects:

    select now()-a.time,a.project_id from project_log as a, projects as b where a.time >= now() - interval '1 day' and a.time <= now() and a.event#>>'{event}' = 'invite_user'  and a.project_id = b.project_id and b.course is null order by a.time desc;

    select count(*) from project_log as a, projects as b where a.time >= now() - interval '1 day' and a.time <= now() and a.event#>>'{event}' = 'invite_user'  and a.project_id = b.project_id and b.course is null;  select count(*) from project_log as a, projects as b where a.time >= now() - interval '2 day' and a.time <= now() - interval '1 day' and a.event#>>'{event}' = 'invite_user'  and a.project_id = b.project_id and b.course is null;    select count(*) from project_log as a, projects as b where a.time >= now() - interval '3 day' and a.time <= now() - interval '2 day' and a.event#>>'{event}' = 'invite_user'  and a.project_id = b.project_id and b.course is null;

Check on our SLO, namely number of projects that took 30s or more to start among the last 100 projects started.

    select count(*) from project_log where event#>>'{event}'='start_project' and time >= now() - interval '1 day';

    select * from (select now()-time as age, project_id,(event#>>'{time}')::INTEGER as t from project_log where event#>>'{event}'='start_project' and time >= now() - interval '1 hour' and time <= now() order by time desc) as foo where t > 20000 order by age;

How long files are taking to open, as perceived by the user:

    select event#>>'{time}' as time_ms, left(event#>>'{filename}',70) as filename, project_id from project_log where time >= now() - interval '1 hour' and time <= now() and event#>>'{time}' is not null and event#>>'{action}'='open' order by time desc limit 100;

Problems people are having right now:

    select NOW() - time as timeago, left(account_id::VARCHAR,6), left(error,70) as error from client_error_log order by time desc limit 50;

    select NOW() - time as timeago, left(account_id::VARCHAR,6), left(error,70) as error from client_error_log where error like 'Error saving%' order by time desc limit 50;

File access for a user with given email address:

    select project_id, file_access_log.account_id, filename, time from file_access_log, accounts where file_access_log.account_id=accounts.account_id and accounts.email_address='x@x.x' order by time desc limit 50;

File access for a user with given account_id

    select * from file_access_log where account_id='...' order by time desc limit 50;

How many patches in the last hour?

    select count(*) from patches where time >= now()-interval '60 min';

Recently created accounts:

    select NOW() - created, first_name, last_name, email_address from accounts where created is not null order by created desc limit 100;

Recently created accounts from gmail.com

    select created, first_name, last_name, email_address from accounts where created is not null and email_address LIKE '%gmail.com%' order by created desc limit 10;

Active projects:

    select NOW() - last_edited as when, left(title,35) as title, project_id from projects where last_edited is not null order by last_edited desc limit 100;

Uncaught exceptions that got reported to the DB (so from storage, hubs, etc.):

    select time, NOW() - time as timeago, event, left(value#>>'{error}',80) from central_log where event = 'uncaught_exception' order by time desc limit 50;

    select * from central_log where event = 'uncaught_exception' order by time desc limit 1;

The syncstring (hence project_id, etc.) for a file with a given path somewhere... (you'll see this in the problems).  This can be kind of slow since there is no index.

    select * from syncstrings where path='2017-01-29-135641.sagews';

or for really common paths:

    select * from syncstrings where path='Homework 1.tex' and last_active is not null order by last_active desc limit 10;

Find active sage worksheets:

    select * from syncstrings where path like '%.sagews' and last_active is not null order by last_active desc limit 10;

Same as above, but return URIs to the files.

    select format('/projects/%s/files/%s', project_id, path) from syncstrings where path like '%.sagews' and last_active is not null order by last_active desc limit 30;

Active syncstrings:

    select string_id, project_id, left(path,50) as path, NOW()-last_active from syncstrings where last_active is not null order by last_active desc limit 20;

Active syncstrings in a particular project:

    select string_id, left(path,50) as path, NOW()-last_active as age from syncstrings where project_id='0bdb2cf7-fd5b-473f-9bfc-801f09efe8a3' and  last_active is not null order by last_active desc limit 20;

Syncstrings with given path and owner:

    select * from syncstrings where path='assignments/2017-01-31/problem-5/problem-5.tex' and array['6ad75132-11ce-4917-9e14-ac9b53a8bd76'::uuid]@>users  is not null order by last_active desc limit 5;

Archived vs. non-archived Syncstrings:

    SELECT count(*), (archived is null) AS is_archived FROM syncstrings GROUP BY is_archived;

What's going on in the DB right now:

    select now()-query_start,client_addr,left(query,130) from pg_stat_activity order by now()-query_start desc;

What people are computing now in sage worksheets:

    select now()-time as timeago, left(input::TEXT,80) from eval_inputs order by time desc limit 100;
    select now()-time as timeago, left(output::TEXT,80) from eval_outputs order by time desc limit 100;

And their errors?



Server's total uptime in seconds:

    SELECT EXTRACT(EPOCH FROM (NOW() - pg_postmaster_start_time)) as start_time_seconds from pg_postmaster_start_time();

System stats for each table:

    SELECT schemaname, relname, seq_scan, seq_tup_read, idx_scan, idx_tup_fetch, n_tup_ins, n_tup_upd, n_tup_del, n_tup_hot_upd, n_live_tup, n_dead_tup, n_mod_since_analyze, last_vacuum, last_autovacuum, last_analyze, last_autoanalyze, vacuum_count, autovacuum_count, analyze_count, autoanalyze_count FROM pg_stat_user_tables;

## Webapp errors

Total in the last hour

    SELECT COUNT(*), severity FROM webapp_errors WHERE time > NOW() - '1 hour'::INTERVAL GROUP BY severity;

Overview of the last day's severe error message, ordered by how often they occurred.

    SELECT COUNT(message) as num, message FROM webapp_errors WHERE severity='error' AND time > NOW() - '24 hour'::INTERVAL GROUP BY message ORDER BY num DESC;

Go through recent webapp errors with some filters. Change the "offset" value...

    SELECT * FROM webapp_errors WHERE severity='error' AND message NOT ILIKE '%xhr%' AND message NOT ILIKE '%websocket%' ORDER BY time LIMIT 1 OFFSET 5;

Undefined properties of objects in the webapp in the past 24 hours:

    SELECT COUNT(message) as num, message FROM webapp_errors WHERE severity='error' AND message LIKE 'Cannot read property%' AND time > NOW() - '24 hour'::INTERVAL GROUP BY message ORDER BY num DESC;

Search for a specific part in an error message in a specific release (first characters of the `smc_git_rev`)

    SELECT * FROM webapp_errors WHERE message LIKE '%call'' of%'  AND smc_git_rev LIKE 'cc75%' ORDER BY time LIMIT 3;

## Analytics

Hourly (or 10minute blocks) active users

    SELECT
        COUNT(DISTINCT(account_id)),
        EXTRACT('isodow' FROM time) as day,
        EXTRACT('hour' FROM time) as hour
        -- , trunc(EXTRACT('minute' FROM time) / 10) as min10
    FROM file_access_log
    WHERE time >= NOW() - '2 week'::interval
    GROUP BY day, hour -- , min10

## Stripe

```
smc=# select stripe_customer#>'{subscriptions}' from accounts where stripe_customer is not null limit 1;

```
