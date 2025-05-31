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
        this.load.spritesheet('enemy', 
            'assets/enemy.png',
            { frameWidth: 30, frameHeight: 47 }
        )
        this.load.image('solid', 'assets/bricks.png')
        this.load.image('flag', 'assets/flag.png')
        this.load.image('key', 'assets/key.png')
    }

    create() {
        this.score = 0
        this.lives = 3
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
        this.cameras.main.startFollow(this.player)

        this.scoreText = this.add.text(this.scale.width / 2, 80, `Score: ${this.score} | Lives: ${this.lives}`, {
            fontSize: '20px',
            fill: '#ffffff'
        }).setOrigin(0.5)
        this.scoreText.setScrollFactor(0)

        this.add.text(0, this.scale.height / 2 - 10, 'Use Arrow Keys to Move and Jump', {
            fontSize: '20px',
            fill: '#ffffff'
        }).setOrigin(0.5)

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

        this.mPlatform_1 = this.physics.add.staticGroup()
        this.mPlatform_1 = this.physics.add.sprite(40 * this.UNIT, 7 * this.UNIT, 'solid')
        .setScale(1, 1)
        .setOrigin(0)
        .setImmovable(true)
        this.mPlatform_1.body.allowGravity = false
        this.mPlatform_1.setVelocityX(200)

        this.keys = this.physics.add.staticGroup()
        this.addKey(-2, 9)
        this.addKey(10, 7)
        this.addKey(18, 11)
        this.addKey(14, 14)
        this.addKey(20, 10)
        this.addKey(34, 10)
        this.addKey(50, 7)

        this.anims.create({
            key: 'enemyMove',
            frames: this.anims.generateFrameNumbers('enemy', { start: 0, end: 3 }),
            frameRate: 10,
            repeat: -1
        })
        this.enemies = this.physics.add.group()
        this.createEnemy(4, 8)
        this.createEnemy(10, 7.5)
        this.createEnemy(28, 10)
        this.createEnemy(28, 13)

        this.flag = this.physics.add.staticGroup()
        this.flag.create(53 * this.UNIT, 13 * this.UNIT, 'flag')
        .setOrigin(0)
        .refreshBody()

        this.physics.add.collider(this.player, this.platforms)
        this.physics.add.collider(this.player, this.mPlatform_1)
        this.physics.add.overlap(this.player, this.flag, () => {
            this.scene.start('Result', { score: this.score, result: "YOU WON"})
        }, null, this)
        this.physics.add.overlap(this.player, this.keys, this.collectKey, null, this)
        this.physics.add.collider(this.player, this.enemies, this.enemyContact, null, this)
        this.physics.add.collider(this.enemies, this.platforms)
    }

    update() {
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
        if (!this.player.body.blocked.down) {
            this.player.anims.play('air', true)
        }

        if (this.player.y > this.scale.height * 2) {
            this.lives -= 1
            if (this.lives > 0) {
                this.scoreText.setText(`Score: ${this.score} | Lives: ${this.lives}`)
                this.player.setVelocityX(0)
                this.player.setVelocityY(0)
                this.player.setPosition(0, 0)
                this.cameras.main.startFollow(this.player)
            }
            else {
                this.scene.start('Result', { score: this.score, result: "YOU LOST"})
            }
        }
        if (this.player.y > this.scale.height) {
            this.player.setVelocityX(0)
            this.cameras.main.stopFollow()
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

        this.enemies.children.iterate((enemy) => {
            const aheadX = enemy.body.velocity.x > 0 ? enemy.x + 10 : enemy.x - 10
            const aheadY = enemy.y + enemy.height / 2 + 1
            const groundAhead = this.platforms.getChildren().some(platform => {
                return Phaser.Geom.Intersects.RectangleToRectangle(
                    new Phaser.Geom.Rectangle(aheadX, aheadY, 2, 2),
                    platform.getBounds()
                )
            })

            if (!groundAhead) {
                enemy.setVelocityX(-enemy.body.velocity.x)
                enemy.toggleFlipX()
            }
            if (enemy.body.blocked.left) {
                enemy.setVelocityX(100)
                enemy.flipX = false
            }
            else if (enemy.body.blocked.right) {
                enemy.setVelocityX(-100)
                enemy.flipX = true
            }
        })
    }

    addPlatform(position = [1, 1], scale = [1, 1], sprite) {
        this.platforms.create(position[0] * this.UNIT, position[1] * this.UNIT, sprite)
        .setScale(scale[0], scale[1])
        .setOrigin(0)
        .refreshBody()
    }

    addKey(x, y) {
        this.keys.create(x * this.UNIT, y * this.UNIT, 'key')
        .setOrigin(0)
        .refreshBody()
    }

    collectKey(_, key) {
        key.destroy()
        this.score += 10
        this.scoreText.setText(`Score: ${this.score} | Lives: ${this.lives}`)
    }

    createEnemy(x, y) {
        let enemy = this.enemies.create(x * this.UNIT, y * this.UNIT, 'enemy')
        .setVelocityX(50)
        enemy.anims.play('enemyMove', true)
    }

    enemyContact(player, enemy) {
        if (player.body.velocity.y > 0 && player.y < enemy.y) {
            enemy.destroy()
            player.setVelocityY(-300)
            this.score += 20
            this.scoreText.setText(`Score: ${this.score} | Lives: ${this.lives}`)
        }
        else {
            enemy.toggleFlipX()
            this.lives -= 1
            if (this.lives <= 0){
                this.scene.start('Result', { score: this.score, result: "YOU LOST"})
            }
            this.scoreText.setText(`Score: ${this.score} | Lives: ${this.lives}`)
            this.player.setVelocityX(0)
            this.player.setVelocityY(0)
            this.player.setPosition(0, 0)
            this.cameras.main.startFollow(this.player)
        }
    }

}