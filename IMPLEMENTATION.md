# Stellwerk Implementation Notes

We want to be able to enforce arbitrary restrictions on the graph.
However, we also want to get some thing working, quickly.
Ideally in a way that would be helpful with Clockwork.
Let's start with a simple layered architecture.

At some point it would be nice to ship

- a template for hexagonal architecture
- a separate CLI call to detect cycles between files

## User Interfaces

### CLI Call

For now, don't take any arguments and just

- ingest all ruby files in current and nested folders
- check against configuration

Later we can add a way to run on single files.

🤔 If this is a tool for rails applications and needs application context, why not just a rake task? But compare packwerk

### CLI Response

- let's not care about compatibility with rubocop or anything like that for now. We probably want an LSP anyway at
  some point.
- set CI compatible exit code

### Configuration

For now, we just need an assignment of files to layers. However, later we probably want "components", "packages" or
something like that as a generalized concept.

OK so... let's assume for now all components are layers. Each component can consist of multiple files or folders.

The simplest way to solve the immediate problem is to just use a YAML structure like so
(assuming hashes in yaml are ordered)

```yaml
layers:
  system_boundary:
    - app/controllers
    - app/jobs
  business_logic:
    - app/services
    - app/interactors
  queries:
    - app/queries
  models:
    - app/models
```

Strings that are folder names would implicitly be completed with `+ "/**/*.rb"`.

Considerations:

- impractical if we want to reuse components in multiple rules
- one-folder layers are a little verbose and I think we'll end up with lots of those
- enqueuing jobs and running jobs from the queue are two different things... in terms of static dependencies,
  jobs should probably live in the business logic layer
- what about lib?
