# StrategyGame

A work in progress/proof of concept for a RTS engine built in Unity3D. 
![](https://i.imgur.com/E7cpAPy.png)

Featuring a bespoke terrain system with user configurable size, shape and quality, with the intention of allowing easy end-user modification and expansion. Terrain is built from a potentially infinite number of height and noise maps, with the only tool required to create or edit these an image editor.

Future development will focus on expanding the UI system to support in-engine creation and selection of different terrain data sets, placement of objects on the terrain, road and decal system, and eventually a turn-based strategy game built on this foundation.

This project makes use of FlatBuffers (https://google.github.io/flatbuffers/) in order to provide size and performance efficient serialization when necessary, as well as JSON for human-readable systems. 
