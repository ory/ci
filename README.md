# circleci-orbs

To publish an orb, install the CLI and run:

```
orb=<name>
circleci orb validate src/${orb}.yml
circleci orb publish increment src/${orb}.yml ory/${orb} patch
```
