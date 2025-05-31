// ------------------------------------------
// MarioJS ~ Arkadiusz Adamczyk
// ------------------------------------------

import { Menu } from './scenes/Menu.js'
import { Scene } from './scenes/Scene.js'

const config = {
    type: Phaser.AUTO,
    title: 'MarioJS',
    parent: 'game-container',
    width: 1280,
    height: 720,
    backgroundColor: '#000000',
    pixelArt: true,
    scene: [
        Menu,
        Scene
    ],
    scale: {
        mode: Phaser.Scale.FIT,
        autoCenter: Phaser.Scale.CENTER_BOTH
    },
    physics: {
        default: 'arcade',
        arcade: {
            gravity: { y: 1000 },
            debug: false
        }
    },
}

new Phaser.Game(config)