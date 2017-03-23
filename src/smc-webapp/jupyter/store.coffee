misc       = require('smc-util/misc')

{Store}  = require('../smc-react')

# Used for copy/paste.  We make a single global clipboard, so that
# copy/paste between different notebooks works.
global_clipboard = undefined

class exports.JupyterStore extends Store
    get_project_id: =>
        return @_project_id

    get_path: =>
        return @_path

    get_directory: =>
        return @_directory

    # Return map from selected cell ids to true, in no particular order
    get_selected_cell_ids: =>
        selected = {}
        cur_id = @get('cur_id')
        if cur_id?
            selected[cur_id] = true
        @get('sel_ids').map (x) ->
            selected[x] = true
            return
        return selected

    # Return sorted javascript array of the selected cell ids
    get_selected_cell_ids_list: =>
        # iterate over *ordered* list so we run the selected cells in order
        # TODO: Could do in O(1) instead of O(n) by sorting only selected first by position...; maybe use algorithm based on size...
        selected = @get_selected_cell_ids()
        v = []
        @get('cell_list').forEach (id) =>
            if selected[id]
                v.push(id)
            return
        return v

    get_cell_index: (id) =>
        cell_list = @get('cell_list')
        if not cell_list? # ordered list of cell id's not known
            return
        if not id?
            return
        i = cell_list.indexOf(id)
        if i == -1
            return
        return i

    get_cur_cell_index: =>
        return @get_cell_index(@get('cur_id'))

    # Get the id of the cell that is delta positions from the
    # cursor or from cell with given id (second input).
    # Returns undefined if no currently selected cell, or if delta
    # positions moves out of the notebook (so there is no such cell).
    get_cell_id: (delta=0, id=undefined) =>
        if id?
            i = @get_cell_index(id)
        else
            i = @get_cur_cell_index()
        if not i?
            return
        i += delta
        cell_list = @get('cell_list')
        if i < 0 or i >= cell_list.size
            return   # .get negative for List in immutable wraps around rather than undefined (like Python)
        return @get('cell_list')?.get(i)

    get_font_size: =>
        return @get_local_storage('font_size') ? @redux.getStore('account')?.get('font_size') ? 14

    get_scroll_state: =>
        return @get_local_storage('scroll')

    get_cursors: =>
        return @syncdb.get_cursors()

    set_global_clipboard: (clipboard) =>
        global_clipboard = clipboard

    get_global_clipboard: =>
        return global_clipboard

    has_uncommitted_changes: =>
        return @syncdb.has_uncommitted_changes()

    get_local_storage: (key) =>
        value = localStorage?[@name]
        if value?
            return misc.from_json(value)?[key]

    get_server_url: =>
        return "#{window?.smc_base_url ? ''}/#{@_project_id}/raw/.smc/jupyter"

    get_blob_url: (extension, sha1) =>
        return "#{@get_server_url()}/blobs/a.#{extension}?sha1=#{sha1}"