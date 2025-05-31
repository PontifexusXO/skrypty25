export class Result extends Phaser.Scene {

    constructor() {
        super('Result')
    }

    init(data) {
        this.score = data.score
        this.result = data.result
    }

    create() {
        this.text = this.add.text(this.scale.width / 2, this.scale.height / 2 - 100, this.result, {
            fontSize: '48px',
            strokeThickness: 2,
            fill: '#ffffff'
        }).setOrigin(0.5)

        this.author = this.add.text(this.scale.width / 2, this.scale.height / 2 - 50, `Your score: ${this.score}`, {
            fontSize: '30px',
            fill: '#ffffff'
        }).setOrigin(0.5)

        this.startButton = this.add.text(this.scale.width / 2, this.scale.height / 2 + 10, 'Menu', {
            fontSize: '32px',
            fill: '#000000',
            backgroundColor: '#ffffff',
            strokeThickness: 2,
            stroke: '#000000',
            padding: { left: 20, right: 20, top: 10, bottom: 10 }
        })
        .setOrigin(0.5)
        .setInteractive( { useHandCursor: true } )
        .on('pointerover', () => this.startButton.setStyle({ backgroundColor: '#aaaaaa' }))
        .on('pointerout', () => this.startButton.setStyle({ backgroundColor: '#ffffff' }))

        this.startButton.on('pointerup', () => {
            this.scene.start('Menu')
        })
    }

}
