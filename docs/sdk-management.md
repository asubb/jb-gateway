# SDK Management with SDKMAN!

The container comes with [SDKMAN!](https://sdkman.io/) pre-installed for the `jb-gateway` user. This allows you to easily install and switch between different versions of Java, Gradle, Maven, and other SDKs.

## Common SDKMAN! Commands

- List available Java versions: `sdk list java`
- Install a specific Java version: `sdk install java 17.0.7-tem`
- Switch Java version: `sdk use java 17.0.7-tem`
- Set default Java version: `sdk default java 17.0.7-tem`

Note: SDKMAN! is initialized in the `.bashrc` of the `jb-gateway` user, so it's available in any new SSH session.
