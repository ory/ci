# ci

To publish an orb, install the CLI and run:

```
orb=<name>
circleci orb validate src/orbs/${orb}.yml
circleci orb publish increment src/orbs/${orb}.yml ory/${orb} patch
```

To create a new orb, run:

```
orb=<name>
circleci orb create ory/$orb
```
