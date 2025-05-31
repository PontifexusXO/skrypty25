export class Scene extends Phaser.Scene {
    
    constructor() {
        super('Scene')
        this.UNIT = 48
    }

    init(data) {
        this.levelKey = data.levelKey
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
        this.load.json(this.levelKey, `levels/${this.levelKey}.json`)
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

        this.anims.create({
            key: 'enemyMove',
            frames: this.anims.generateFrameNumbers('enemy', { start: 0, end: 3 }),
            frameRate: 8,
            repeat: -1
        })

        this.scoreText = this.add.text(this.scale.width / 2, 80, `Score: ${this.score} | Lives: ${this.lives}`, {
            fontSize: '20px',
            fill: '#ffffff'
        })
        .setOrigin(0.5)
        .setScrollFactor(0)

        this.add.text(0, this.scale.height / 2 - 10, 'Use Arrow Keys to Move and Jump', {
            fontSize: '20px',
            fill: '#ffffff'
        }).setOrigin(0.5)

        this.loadLevel('level1')
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
                this.scene.start('Result', { score: this.score, result: 'YOU LOST'})
            }
        }
        if (this.player.y > this.scale.height) {
            this.player.setVelocityX(0)
            this.cameras.main.stopFollow()
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
                enemy.setVelocityX(150)
                enemy.flipX = false
            }
            else if (enemy.body.blocked.right) {
                enemy.setVelocityX(-150)
                enemy.flipX = true
            }
        })

        this.mPlatforms.children.iterate((platform) => {
            if (platform.x >= platform.getData('originalX') + 3 * this.UNIT) {
                platform.setVelocityX(-200)

            } 
            else if (platform.x <= platform.getData('originalX') - 3 * this.UNIT) {
                platform.setVelocityX(200)
            }
            if (this.player.body.blocked.down &&
                platform.body.touching.up &&
                Phaser.Geom.Intersects.RectangleToRectangle(
                this.player.getBounds(),
                platform.getBounds())) {
                    this.player.body.velocity.x += platform.body.velocity.x
                }
        })
    }

    collectKey(_, key) {
        key.destroy()
        this.score += 10
        this.scoreText.setText(`Score: ${this.score} | Lives: ${this.lives}`)
    }

    enemyContact(player, enemy) {
        if (player.body.velocity.y > 0 &&
            player.body.bottom <= enemy.body.top + 10 &&
            player.body.right > enemy.body.left &&
            player.body.left < enemy.body.right) {
                enemy.destroy()
                player.setVelocityY(-300)
                this.score += 20
                this.scoreText.setText(`Score: ${this.score} | Lives: ${this.lives}`)
        }
        else {
            enemy.toggleFlipX()
            if (enemy.flipX) {
                enemy.setVelocityX(-150)
            }
            else {
                enemy.setVelocityX(150)
            }

            this.lives -= 1
            if (this.lives <= 0){
                this.scene.start('Result', { score: this.score, result: 'YOU LOST'})
            }

            this.scoreText.setText(`Score: ${this.score} | Lives: ${this.lives}`)
            this.player.setVelocityX(0)
            this.player.setVelocityY(0)
            this.player.setPosition(0, 0)
            this.cameras.main.startFollow(this.player)
        }
    }

    addPlatform(position = [1, 1], scale = [1, 1]) {
        this.platforms.create(position[0] * this.UNIT, position[1] * this.UNIT, 'solid')
        .setScale(scale[0], scale[1])
        .setOrigin(0)
        .refreshBody()
    }

    addMovingPlatform(position = [1, 1], scale = [1, 1]) {
        this.mPlatforms.create(position[0] * this.UNIT, position[1] * this.UNIT, 'solid')
        .setScale(scale[0], scale[1])
        .setOrigin(0)
        .setImmovable(true)
        .setVelocityX(200)
        .setData('originalX', position[0] * this.UNIT)
        .body.allowGravity = false
    }

    addKey(position = [1, 1]) {
        this.keys.create(position[0] * this.UNIT, position[1] * this.UNIT, 'key')
        .setOrigin(0)
        .refreshBody()
    }

    addEnemy(position = [1, 1]) {
        let enemy = this.enemies.create(position[0] * this.UNIT, position[1]* this.UNIT, 'enemy').setVelocityX(150)
        enemy.anims.play('enemyMove', true)
    }

    loadLevel(levelKey) {
        const levelData = this.cache.json.get(levelKey)

        this.platforms = this.physics.add.staticGroup()
        levelData.platforms.forEach(p => {
            this.addPlatform(p.position, p.scale)
        })

        this.mPlatforms = this.physics.add.group()
        levelData.movingPlatforms.forEach(m => {
            this.addMovingPlatform(m.position, m.scale)
        })

        this.keys = this.physics.add.staticGroup()
        levelData.keys.forEach(k => {
            this.addKey(k.position)
        })

        this.enemies = this.physics.add.group()
        levelData.enemies.forEach(e => {
            this.addEnemy(e.position, e.scale)
        })

        this.flag = this.physics.add.staticGroup()
        levelData.flag.forEach(f => {
            this.flag.create(f.position[0] * this.UNIT, f.position[1] * this.UNIT, 'flag')
            .setOrigin(0)
            .refreshBody()
        })

        this.physics.add.collider(this.player, this.platforms)
        this.physics.add.collider(this.player, this.mPlatforms)
        this.physics.add.overlap(this.player, this.flag, () => {
            this.scene.start('Result', { score: this.score, result: 'YOU WON'})
        }, null, this)
        this.physics.add.overlap(this.player, this.keys, this.collectKey, null, this)
        this.physics.add.collider(this.player, this.enemies, this.enemyContact, null, this)
        this.physics.add.collider(this.enemies, this.platforms)
    }

}