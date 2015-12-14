###
Some convenient command-line shortcuts.  If you're working on the command line, do

    require('./c.coffee')

The functiosns below in some cases return things, and in some cases set global variables!  Read docs.

###


# get a connection to the db
global.database = ->
    return global.db = require('./smc-hub/rethink').rethinkdb(hosts:['db0'], pool:1)
console.log("database() -- sets global variable db to a database")

# make the global variable s be the compute server
global.compute_server = () ->
    return require('smc-hub/compute-client').compute_server
        db_hosts:['db0']
        cb:(e,s)->
            global.s=s
console.log("compute_server() -- sets global variable s to compute server")

# make the global variable p be the project with given id and the global variable s be the compute server
global.project = (id) ->
    require('smc-hub/compute-client').compute_server
        db_hosts:['db0']
        cb:(e,s)->
            global.s=s
            s.project
                project_id:id
                cb:(e,p)->global.p=p

console.log("project('project_id') -- set p = project, s = compute server")
