# Xcode-Tools
A Swift-based utility for installing Xcode and Command Line Tools

**Work in progress!**

## Summary and Purpose

This utility helps prevent a "chicken and the egg" scenario which is fairly common on fresh macOS installs. By default, macOS does not come with many developer tools installed, yet to do anything useful we need those tools installed. Working in a headless environment, such as CircleCI when we are building our Xcode images, we need a way to install the Command Line Tools and Xcode simply and easily without any dependencies from the command line.

Although macOS ships with Ruby, it is fairly restrictive and does not play nicely with various gems. Therefore, using an existing utility, such as Xcode-Install is often not possible. As this utlity is standalone, regardless of how broken your environment might be, you can still quickly and easily re/install the Command Line Tools and Xcode.

The Command Line Tools installer portion of the utility also does not rely on Software Update which, at times, can also be unreliable and will not let you choose a specific version of the tools to install.

## How to Install



## Using Xcode-Tools



## Feature Suggestions and Reporting Bugs

If you find a bug, please file an [issue](https://github.com/BytesGuy/Xcode-Tools/issues), including as much information as possible.

If you have any suggestions, or bug fixes, please open a [pr](https://github.com/BytesGuy/Xcode-Tools/pulls) - any help is appreciated!
