export class Scene extends Phaser.Scene {
    
    constructor() {
        super('Scene')
        this.UNIT = 48
    }

    preload() {
        this.load.spritesheet('player', 
            'assets/player.png',
            { frameWidth: 24, frameHeight: this.UNIT }
        )
        this.load.image('solid', 'assets/bricks.png')
        this.load.image('flag', 'assets/flag.png');
    }

    addPlatform(position = [1, 1], scale = [1, 1], sprite) {
        this.platforms.create(position[0] * this.UNIT, position[1] * this.UNIT, sprite)
        .setScale(scale[0], scale[1])
        .setOrigin(0)
        .refreshBody()
    }

    create() {
        this.controlKeys = this.input.keyboard.createCursorKeys()
        this.anims.create({
            key: 'idle',
            frames: this.anims.generateFrameNumbers('player', { start: 0, end: 1 }),
            frameRate: 2,
            repeat: -1
        })
        this.anims.create({
            key: 'move',
            frames: this.anims.generateFrameNumbers('player', { start: 4, end: 7 }),
            frameRate: 15,
            repeat: -1
        })
        this.anims.create({
            key: 'air',
            frames: [{ key: 'player', frame: 2 }],
            frameRate: 10
        })
        this.player = this.physics.add.sprite(0, 0, 'player')
        .setBounce(0)
        this.inputEnabled = true
        this.cameras.main.startFollow(this.player)
        this.cameras.main.setLerp(1, 1)

        this.add.text(0, this.scale.height / 2 - 10, 'Use Arrow Keys to Move and Jump', {
            fontSize: '20px',
            fill: '#ffffff'
        })
        .setOrigin(0.5)

        this.platforms = this.physics.add.staticGroup()
        this.addPlatform([-2, 10], [10, 1], 'solid')
        this.addPlatform([8, 8], [1, 3], 'solid')
        this.addPlatform([9, 8], [4, 1], 'solid')
        this.addPlatform([13, 8], [1, 7], 'solid')
        this.addPlatform([13, 15], [3, 1], 'solid')
        this.addPlatform([20, 15], [12, 1], 'solid')
        this.addPlatform([32, 14], [1, 2], 'solid')
        this.addPlatform([28, 13], [2, 1], 'solid')
        this.addPlatform([20, 11], [2, 1], 'solid')
        this.addPlatform([25, 11], [2, 1], 'solid')
        this.addPlatform([29, 9], [2, 1], 'solid')
        this.addPlatform([32, 7], [3, 1], 'solid')
        this.addPlatform([51, 15], [6, 1], 'solid')
        this.addPlatform([56, 7], [1, 8], 'solid')

        this.flag = this.physics.add.staticGroup()
        this.flag.create(53 * this.UNIT, 13 * this.UNIT, 'flag')
        .setOrigin(0)
        .refreshBody()

        this.mPlatform_1 = this.physics.add.staticGroup()
        this.mPlatform_1 = this.physics.add.sprite(40 * this.UNIT, 7 * this.UNIT, 'solid')
            .setScale(1, 1)
            .setOrigin(0)
            .setImmovable(true)
        this.mPlatform_1.body.allowGravity = false
        this.mPlatform_1.setVelocityX(200)

        this.physics.add.collider(this.player, this.platforms)
        this.physics.add.collider(this.player, this.mPlatform_1)
        this.physics.add.overlap(this.player, this.flag, winGame, null, this)
        function winGame() {
            this.text = this.add.text(53 * this.UNIT, 12 * this.UNIT, 'YOU WON!', {
                fontSize: '48px',
                fill: '#ffffff'
            })
            .setOrigin(0.5)

            this.cameras.main.stopFollow()
            this.inputEnabled = false
            this.player.setVelocityX(0)

            this.time.delayedCall(3000, () => {
                this.scene.start('Menu')
            })
        }
    }

    update() {
        this.player.setVelocityX(0)

        if (this.inputEnabled) {
            if (this.controlKeys.left.isDown) {
                this.player.flipX = true
                this.player.setVelocityX(-200)
                this.player.anims.play('move', true)
            }
            else if (this.controlKeys.right.isDown) {
                this.player.flipX = false
                this.player.setVelocityX(200)
                this.player.anims.play('move', true)
            }
            else {
                this.player.setVelocityX(0)
                this.player.anims.play('idle', true)
            }

            if (this.controlKeys.up.isDown && this.player.body.blocked.down) {
                this.player.setVelocityY(-480)
                this.player.anims.play('air', true)
            }
        }

        if (!this.player.body.blocked.down) {
            this.player.anims.play('air', true)
        }
        else if (!this.inputEnabled) {
            this.player.setVelocityX(0)
            this.player.anims.play('idle', true)
        }

        if (this.player.y > this.scale.height * 2) {
            this.player.setVelocityX(0)
            this.player.setVelocityY(0)
            this.player.setPosition(0, 0)
            this.cameras.main.startFollow(this.player)
        }
        if (this.player.y > this.scale.height) {
            this.player.setVelocityX(0)
            this.cameras.main.stopFollow();
        }

        if (this.mPlatform_1.x >= 45 * this.UNIT) {
            this.mPlatform_1.setVelocityX(-200)
            if (this.player.body.touching.down && this.mPlatform_1.body.touching.up) {
                this.player.setVelocityX(-200)
            }
        } 
        else if (this.mPlatform_1.x <= 38 * this.UNIT) {
            this.mPlatform_1.setVelocityX(200)
            if (this.player.body.touching.down && this.mPlatform_1.body.touching.up) {
                this.player.setVelocityX(200)
            }
        }
    }

}