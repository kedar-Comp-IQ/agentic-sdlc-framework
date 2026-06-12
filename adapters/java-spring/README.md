# Adapter: Java / Spring (Maven)

Maps the technology-agnostic core to a Java 17/21 + Spring Boot + Maven multi-module stack.
This is the reference adapter (the source system was built on it), so it's the most
complete.

## Tooling map

| Concern | Tool | Gate |
|---------|------|------|
| Build / modules | Maven multi-module (one module per {{BOUNDARY_TERM}}) | enforcer plugin pins Java + Maven min versions |
| Boundary isolation (IR-01/12) | **ArchUnit** | a test per boundary rule; fails the build on violation |
| Unit/integration tests | JUnit 5 + Testcontainers | `mvn verify` |
| Coverage | **JaCoCo** | line coverage ≥ 80% on changed modules (fail build) |
| Mutation testing | **PIT** | ≥ 70% on critical modules, behind a `pit` profile |
| SAST | **SpotBugs + FindSecBugs** | effort=Max, threshold=Low, fail on error |
| Dependency CVEs | **OWASP dependency-check** | `failBuildOnCVSS=9.0` (Critical blocks) |
| License compliance | **license-maven-plugin** | allowlist; review-required licenses escalate |

## Coding standard (essentials)

- Package by {{BOUNDARY_TERM}}: `com.{{ORG}}.{{PROJECT}}.{boundary}.{module}`. No boundary
  imports another boundary's internals except `{{SHARED_BOUNDARY}}`.
- **Layering (IR-12):** Controller → Service → Repository. No business logic in
  controllers; no persistence in services; all JPA in repositories.
- **Parameterized queries only (IR-10):** Spring Data `@Query` with named params or
  QueryDSL. Never string-concatenated JPQL/SQL.
- **Stateless beans (IR-07):** no `static` mutable state; tenant context via request scope.
- **DTOs at the edge:** entities never serialize to the API; map to DTOs.
- Lombok allowed; keep generated surface out of coverage math.

## ArchUnit boundary test (the IR-01 mechanism)

```java
// src/test/java/.../ArchitectureTest.java
@AnalyzeClasses(packages = "com.{{ORG}}.{{PROJECT}}")
class ArchitectureTest {
    @ArchTest static final ArchRule boundaries_do_not_leak =
        slices().matching("com.{{ORG}}.{{PROJECT}}.(*)..")
                .should().notDependOnEachOther()
                .ignoreDependency(alwaysTrue(),
                    resideInAPackage("..{{SHARED_BOUNDARY}}.."));   // shared is importable

    @ArchTest static final ArchRule layering =
        layeredArchitecture().consideringAllDependencies()
            .layer("Controller").definedBy("..controller..", "..routes..")
            .layer("Service").definedBy("..service..")
            .layer("Repository").definedBy("..repository..")
            .whereLayer("Controller").mayNotBeAccessedByAnyLayer()
            .whereLayer("Repository").mayOnlyBeAccessedByLayers("Service");
}
```

## CI verify (snippet → `.github/workflows/java-verify.yml`)

```yaml
name: java-verify
on: { workflow_call: {}, pull_request: { branches: ["{{DEFAULT_BRANCH}}"] } }
jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with: { distribution: temurin, java-version: '21', cache: maven }
      - run: mvn -B verify                       # tests + JaCoCo gate + ArchUnit + SpotBugs
      - run: mvn -B org.owasp:dependency-check-maven:check   # CVE gate (fail ≥ 9.0)
      - run: mvn -B license:check-file-header || true        # license allowlist
```

## Migration standard (Flyway)

- One source of truth for version numbers; **never trust a V-number from another module's
  notes** — check the canonical migration directory / standard before allocating one
  (version collisions across parallel branches are a classic failure).
- Migrations are forward-only in shared environments; destructive changes (drops) are
  **Tier 4** (change-control-tiers.md).
- Every migration is idempotent-safe and reviewed for tenant-scope correctness (IR-06).

## SAST waiver discipline

SpotBugs/FindSecBugs false positives (e.g. Spring DI exposing internal representation,
slf4j CRLF on already-sanitized input) get **narrow, per-pattern** waivers in
`spotbugs-exclude.xml`, reviewed in the PR — never a blanket category suppression
(waivers-and-incidents.md). New modules predictably need a first-PR waiver for the
framework-level patterns; land it in the same PR as the module.
