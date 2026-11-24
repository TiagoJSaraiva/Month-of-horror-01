class_name PhysicsLayers
extends RefCounted
## Máscaras das camadas de física nomeadas em Project Settings (ver docs/arquitetura.md).
## Cada valor é o bit da camada, pronto para collision_mask e consultas de raio.

const WORLD := 1 << 0
const PLAYER := 1 << 1
const INTERACTABLE := 1 << 2
const WATER := 1 << 3
const ENEMY := 1 << 4
const HURTBOX := 1 << 5
const LIGHT_SENSOR := 1 << 6
