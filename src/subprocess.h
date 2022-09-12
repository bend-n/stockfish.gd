#ifndef ENGINE_H
#define ENGINE_H

#include <Godot.hpp>

namespace godot {

class Subprocess : public Reference {
  GODOT_CLASS(Subprocess, Reference)

private:
public:
  static void _register_methods();
  void _init();
  void send(String text);
};

} // namespace godot
#endif