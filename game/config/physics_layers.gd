class_name PhysicsLayers
extends RefCounted
## Máscaras das camadas de física nomeadas em Project Settings (ver docs/arquitetura.md).
## Cada valor é o bit da camada, pronto para collision_mask e consultas de raio.

const WORLD: int = 1 << 0
const PLAYER: int = 1 << 1
const INTERACTABLE: int = 1 << 2
const WATER: int = 1 << 3
const ENEMY: int = 1 << 4
const HURTBOX: int = 1 << 5
const LIGHT_SENSOR: int = 1 << 6
