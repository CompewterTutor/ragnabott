const { SlashCommandBuilder } = require('@discordjs/builders');
const { REST } = require('@discordjs/rest');
const { Routes } = require('discord-api-types/v9');
const { clientId, guildId, token } = require('./config.json');

const commands = [
    new SlashCommandBuilder().setName('ping').setDescription('Replies with ping'),
    new SlashCommandBuilder().setName('server').setDescription('Replies with server information'),
    new SlashCommandBuilder().setName('ping').setDescription('Replies with ping'),

]