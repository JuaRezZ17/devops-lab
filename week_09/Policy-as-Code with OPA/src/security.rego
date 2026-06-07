package main

deny contains message if {
  input.kind == "Deployment"
  not input.spec.template.spec.securityContext.runAsNonRoot

  name := input.metadata.name

  message := sprintf("Deployment %q must set spec.template.spec.securityContext.runAsNonRoot: true", [name])
}