extends Node

func load_resource(path: String):
    if !ResourceLoader.exists(path): return null
    var resource := ResourceLoader.load(path)
    return resource

func load_resource_async(path: String, callback: Callable, process: Callable):
    var loading_progress: Array[float] = []
    if !ResourceLoader.exists(path): return null
    ResourceLoader.load_threaded_request(path)
    while true:
        var status = ResourceLoader.load_threaded_get_status(path, loading_progress)
        if status == ResourceLoader.THREAD_LOAD_LOADED:
            var resource = ResourceLoader.load_threaded_get(path)
            callback.call(resource)
        elif status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
            process.call(loading_progress[0])
        elif status == ResourceLoader.THREAD_LOAD_FAILED:
            break
        await get_tree().process_frame

func save_resource(resource: Resource):
    for prop in resource.get_property_list():
        if !(prop["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE):
            continue
        var value = resource.get(prop["name"])
        if !(value is Resource):
            continue
        ResourceSaver.save(value, value.resource_path)

    ResourceSaver.save(resource, resource.resource_path)
