#include "MyLib/MyLib.hpp"
#include <iostream>

using namespace Example::MyLib;

void message(const std::string& text) {
    std::cout << text << std::endl;
    std::cout << "MyLib version: "
              << Config::VersionString
              << std::endl;
}
