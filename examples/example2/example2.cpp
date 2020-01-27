#include <Example/Library/Config.hpp>
#include <iostream>

using namespace Example::Library;

int main() {
  std::cout << "Main project name: " << Config::MainProjectName
            << "\nProject name     : " << Config::ProjectName
            << "\nInstall prefix   : " << Config::InstallPrefix << std::endl;
  return 0;
}
