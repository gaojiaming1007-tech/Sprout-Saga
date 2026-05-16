extends Node

enum ParticleType {
    ## 开垦田
    Hoe
}

const PARTICLE_TYPE = {
    ParticleType.Hoe: 'hoe'
}

func spawn_particle(type: ParticleType, at_position: Vector2, callback: Callable = func(): pass ):
    var particle: GPUParticles2D = ResourceManager.load_resource("res://particles/%s.tscn" % [PARTICLE_TYPE[type]]).instantiate()
    particle.global_position = at_position
    particle.emitting = true
    GameManager.game.current_level_instance.add_child(particle)
    await particle.finished
    particle.queue_free()
    callback.call()
