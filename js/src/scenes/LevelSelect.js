export class LevelSelect extends Phaser.Scene {

    constructor() {
        super('LevelSelect')
    }

    preload() {
        this.load.json('levelList', 'levels/levels.json')
    }

    create() {
        this.add.text(this.scale.width / 2, 100, 'Select a Level', {
            fontSize: '48px',
            strokeThickness: 2,
            fill: '#ffffff'
        }).setOrigin(0.5)

        const levelList = this.cache.json.get('levelList')

        levelList.forEach((levelKey, index) => {
            const button = this.add.text(this.scale.width / 2, 200 + index * 100, levelKey, {
                fontSize: '24px',
                fill: '#ffffff',
                backgroundColor: '#000000',
                padding: { x: 10, y: 5 }
            })
            .setOrigin(0.5)
            .setInteractive({ useHandCursor: true })
            .on('pointerover', () => button.setStyle({ fill: '#aaaaaa' }))
            .on('pointerout', () => button.setStyle({ fill: '#ffffff' }))
            .on('pointerdown', () => {
                this.scene.start('Scene', { levelKey })
            })
        })
    }

}
