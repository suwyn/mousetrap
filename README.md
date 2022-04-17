# Mousetrap

A simple program that tracks how often interact with an application using the mouse vs the keyboard.

It's meant to motivate you to learn keyboard shortcuts and be more efficient when using x11 applications.

## Usage

Setup a mousetrap for a paticular application:

> ./mousetrap toggle VSCodium

Watch the trap in your console:

> watch -n1 ./mousetrap check

### xfce panel plugin

Included is a genmon script for xfce which can be used to add Mousetrap to a panel.

Configure a generic monitor to execute `xfce-mousetrap-plugin` every 1 second.

![panel plugin](./docs/panel-plugin.png)
