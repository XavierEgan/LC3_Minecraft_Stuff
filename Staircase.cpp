#include <mcpp/mcpp.h>

int main() {

    mcpp::MinecraftConnection mc;
    
    const int stairHeight = 20;
    mcpp::Coordinate corner1(2, 90, stairHeight);
    mcpp::Coordinate corner2(-2, 90, 0);
    
    for (int i=stairHeight; i >= 0; i--) {
        mc.setBlocks(corner1, corner2, 1);

        corner1.y += 1;
        corner2.y += 1;
        corner1.z -= 1;
    }

}