#include "subprocess.h"
using namespace godot;

#include <iostream>
#include <sstream>

using namespace godot;

void Subprocess::_register_methods() {
  register_signal<Subprocess>((char *)"recieve", "text", GODOT_VARIANT_STRING);
  register_method("send", &Subprocess::send);
}

void Subprocess::_init() {
  String line;
  bool running = true;
  while (running && getline(std::cin, line)) {
    std::istringstream iss(line);
    Godot::print(line);
  }
}

static void Subprocess::send(const String &text) {
  std::cout << text << std::endl;
}
