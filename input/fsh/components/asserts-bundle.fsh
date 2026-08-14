// The seventeen asserts that every searchset scenario in the Nictiz set shares,
// in the original order. Verified byte identical across scenarios 1.1, 1.2, 1.4,
// 2.1 and 2.5 before extracting them here.
//
// Generated from the source with scripts/nictiz-to-fsh.py; do not retype the
// FHIRPath expressions by hand, the backslash escaping is easy to get wrong.
//
// Note: the last assert uses the Touchstone rule extension, not the
// Interoplab-CL-ext-assert-rule from the Conformancelab guide. Kept as it came
// from Nictiz. Whether Conformancelab honours the Touchstone url is an open
// question, see docs/scenario-selection.md.

RuleSet: assertsBundleSearchsetCore
* test[=].action[+].assert
  * description = "Confirm that the returned resource type is Bundle."
  * direction = #response
  * resource = "Bundle"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the returned Bundle type is searchset."
  * direction = #response
  * expression = "Bundle.type"
  * operator = #equals
  * stopTestOnFail = false
  * value = "searchset"
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that all returned resources contain an Resource.id except when temporary ids are used in the Bundle. The only time that a resource does not have an id is when it is being submitted to the server using a create operation: https://www.hl7.org/fhir/STU3/resource-definitions.html#Resource.id"
  * direction = #response
  * expression = "Bundle.entry.all( $this.fullUrl.matches('^urn:oid:[0-2](\\\\.(0|[1-9]\\\\d*))*$') or $this.fullUrl.matches('^urn:uuid:[A-Fa-f\\\\d]{8}-[A-Fa-f\\\\d]{4}-[A-Fa-f\\\\d]{4}-[A-Fa-f\\\\d]{4}-[A-Fa-f\\\\d]{12}$') or $this.resource.id.exists())"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that all returned resources except OperationOutcome and Binary contain a meta.profile tag."
  * direction = #response
  * expression = "Bundle.entry.resource.where(is(OperationOutcome).not()).where(is(Binary).not()).where(meta.profile.empty()).empty()"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the fullUrl does not disagree with the id in the resource, see http://hl7.org/fhir/stu3/bundle-definitions.html#Bundle.entry.fullUrl"
  * direction = #response
  * expression = "Bundle.entry.where(fullUrl.exists() and resource.id.exists()).all($this.fullUrl.endsWith($this.resource.id))"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the fullUrl is an absolute URL, an uuid or an oid."
  * direction = #response
  * expression = "Bundle.entry.fullUrl.all( startsWith('http://') or startsWith('https://') or matches('^urn:oid:[0-2](\\\\.(0|[1-9]\\\\d*))*$') or matches('^urn:uuid:[A-Fa-f\\\\d]{8}-[A-Fa-f\\\\d]{4}-[A-Fa-f\\\\d]{4}-[A-Fa-f\\\\d]{4}-[A-Fa-f\\\\d]{12}$') )"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the returned Bundle conforms to the base FHIR specification and the resources to the stated profiles in the meta.profile tag."
  * direction = #response
  * stopTestOnFail = false
  * validateProfileId = "Bundle-profile"
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that all Coding elements contain both a .system and a .code."
  * direction = #response
  * expression = "Bundle.descendants().where($this.is(Coding)).all(system.exists() and code.exists())"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the OID of the zib valueset is not used for the system of a coding element."
  * direction = #response
  * expression = "Bundle.descendants().where($this.is(coding)).where(system.startsWith('urn:oid:2.16.840.1.113883.2.4.3.11.60.40.2')).exists().not()"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that all CodeableConcept elements contain either a coding.display or a text value if no Coding exists or has an extension (e.g. a nullFlavor or data-absent-reason extension). For more information see https://informatiestandaarden.nictiz.nl/wiki/FHIR:V1.0_FHIR_IG_STU3Use_of_coded_concepts."
  * direction = #response
  * expression = "Bundle.descendants().where($this.is(CodeableConcept)) .all(coding.display.exists() or text.exists() or extension.exists())"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that all References have a display value, see https://informatiestandaarden.nictiz.nl/wiki/FHIR:V1.0_FHIR_IG_STU3#Use_of_the_reference_datatype."
  * direction = #response
  * expression = "Bundle.descendants().where($this.is(Reference)).all(display.exists() or extension.where(url = 'http://hl7.org/fhir/StructureDefinition/data-absent-reason').exists() or extension.where(url = 'http://hl7.org/fhir/StructureDefinition/iso21090-nullFlavor').exists())"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that all Identifiers have both a .system and a .value. In rare cases where a general category of identifiers can be used, .type can replace .system. Edge cases for both .system and .type to be unknown are not applicable to Nictiz. For more information, see https://www.hl7.org/fhir/stu3/datatypes.html#Identifier."
  * direction = #response
  * expression = "Bundle.descendants().where($this.is(Identifier)).all((system.exists() or type.exists()) and value.exists())"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that Bundle does not use Burgerservicenummer (BSN) anywhere."
  * direction = #response
  * expression = "Bundle.descendants().select(identifier.where(system = 'http://fhir.nl/fhir/NamingSystem/bsn').where(value.empty().not() and value.extension.exists().not())).count() = 0"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the returned Bundle total value matches or is less than the number of entries in the Bundle. The included resources should not be counted as entries in the Bundle.total."
  * direction = #response
  * expression = "Bundle.total.exists() implies (Bundle.total.toInteger() <= Bundle.entry.where(search.empty() or search.mode = 'match').count())"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the returned Bundle contains a self link."
  * direction = #response
  * expression = "Bundle.link.where(relation = 'self' and url.exists()).exists()"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that Bundle does not use Burgerservicenummer (BSN) in the self link."
  * direction = #response
  * expression = "Bundle.link.url.contains('http://fhir.nl/fhir/NamingSystem/bsn') = false"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * extension[+].url = "http://touchstone.aegis.net/touchstone/fhir/testing/StructureDefinition/testscript-assert-rule"
  * extension[=].extension[+].url = "ruleId"
  * extension[=].extension[=].valueId = "assert-response-queryParamsInSelfLink"
  * description = "Confirm that the parameters in the request URL are all handled by the server, by inspecting the self link."
  * stopTestOnFail = false
  * warningOnly = true
