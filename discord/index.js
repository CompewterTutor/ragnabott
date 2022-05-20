require('dotenv').config()
console.log(process.env) //@TODO REMOVE

//ES6
import 'dotenv/config'

const { Client, Intents } = require('discord.js');
const { app_config } = dotenv.config()
const { discord_token } = process.env.

// when the client is ready, run this code (only once)
client.once('ready',() => {
    console.log('Ready!');
})

//client.login(discord_token)