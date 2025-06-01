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
            const button = this.add.text(this.scale.width / 2, 200 + index * 100, `-- ${levelKey} --`, {
                fontSize: '24px',
                fill: '#ffffff',
                padding: { x: 10, y: 5 }
            })
            .setOrigin(0.5)
            .setInteractive({ useHandCursor: true })
            .on('pointerover', () => button.setStyle({ fill: '#aaaaaa' }))
            .on('pointerout', () => button.setStyle({ fill: '#ffffff' }))
            .on('pointerup', () => {
                this.scene.start('Scene', { levelKey: levelKey })
            })
        })

        const button = this.add.text(this.scale.width / 2, this.scale.height - 200, 'Generate Level', {
                fontSize: '32px',
                fill: '#000000',
                backgroundColor: '#ffffff',
                strokeThickness: 2,
                stroke: '#000000',
                padding: { left: 20, right: 20, top: 10, bottom: 10 }
            })
            .setOrigin(0.5)
            .setInteractive({ useHandCursor: true })
            .on('pointerover', () => button.setStyle({ backgroundColor: '#aaaaaa' }))
            .on('pointerout', () => button.setStyle({ backgroundColor: '#ffffff' }))
            .on('pointerup', () => {
                this.generateLevel()
        })
    }

    generateLevel() {
        const widthBlocks = 50
        const heightBlocks = 10
        const level = {
            platforms: [],
            movingPlatforms: [],
            keys: [],
            enemies: [],
            flag: []
        }

        level.platforms.push({ position: [-2, heightBlocks], scale: [widthBlocks + 2, 1] })

        let x = 5
        while (x < widthBlocks - 2) {
            const platformWidth = Phaser.Math.Between(1, 5)
            const gap = Phaser.Math.Between(0, 3)
            const platformHeight = Phaser.Math.Between(heightBlocks - 4, heightBlocks - 1)

            level.platforms.push({ position: [x, platformHeight], scale: [platformWidth, 1] })

            if (Math.random() < 0.3) {
                const mpX = x + Phaser.Math.Between(0, platformWidth)
                const mpY = platformHeight - Phaser.Math.Between(1, 3)
                level.movingPlatforms.push({ position: [mpX, mpY], scale: [1, 1] })
            }

            x += platformWidth + gap
        }

        const pillarCount = Phaser.Math.Between(2, 8)
        for (let i = 0; i < pillarCount; i++) {
            const x = Phaser.Math.Between(5, widthBlocks - 2)
            const h = Phaser.Math.Between(1, 2)
            const y = heightBlocks - 1 - h
            level.platforms.push({ position: [x, y], scale: [1, h] })
        }

        const keyCount = Phaser.Math.Between(2, 10)
        for (let i = 0; i < keyCount; i++) {
            const x = Phaser.Math.Between(2, widthBlocks - 2)
            const y = Phaser.Math.Between(heightBlocks - 4, heightBlocks - 1)
            level.keys.push({ position: [x, y] })
        }

        const enemyCount = Phaser.Math.Between(2, 10)
        for (let i = 0; i < enemyCount; i++) {
            const x = Phaser.Math.Between(2, widthBlocks - 2)
            const y = Phaser.Math.Between(heightBlocks - 4, heightBlocks - 1)
            level.enemies.push({ position: [x, y] })
        }

        const flagY = Phaser.Math.Between(heightBlocks - 1, heightBlocks - 3)
        level.flag.push({ position: [widthBlocks - 1, flagY] })

        this.scene.start('Scene', { levelData: level })
    }

}
