extends SceneTree
const CATALOG = preload("res://scripts/systems/activity_catalog.gd")
const ACTIVITY = preload("res://scripts/minigames/district_activity.gd")
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    if CATALOG.ACTIVITIES.size()!=13:
        quit(1)
        return
    for id in CATALOG.ACTIVITIES:
        var activity = ACTIVITY.new()
        activity.setup(id)
        root.add_child(activity)
        await process_frame
        if activity.status==null or activity.area.get_child_count()==0:
            push_error("Atividade sem interface: "+id)
            quit(2)
            return
        activity.queue_free()
        await process_frame
    print("Treze atividades carregadas.")
    quit(0)
