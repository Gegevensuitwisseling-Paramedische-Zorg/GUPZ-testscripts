// Asserts that come from open-GUPZ rather than from the imported Nictiz
// scripts. Kept in their own file so that provenance stays visible: everything
// here tests a sentence in the GUPZ specification, and nothing here was in the
// material this repository started from.


// pdfa.md requires the data platform to offer every document reference as a
// reference to a Binary resource, so that the Retrieve Document transaction
// reads the Binary. The specification is in Dutch; this is the English of that
// sentence.
//
// Nothing in the imported set tests this. A platform that returns the PDF
// inline, base64 encoded in DocumentReference.content.attachment.data, passes
// every other assert in the Data platform set. Scenario 1.4 does read a Binary,
// but it reads whatever url the response gave it, so serving a plain http url
// gets through there as well. That is scenario 2.5, which exists for servers
// that work that way; for GUPZ it is not conformant.
//
// Two asserts, of different weight.
//
// The first is hard. The requirement is a MUST in the specification, in the
// indicative that open-GUPZ uses throughout, and it says what has to be there.
// The url is matched on containing 'Binary/' rather than on starting with it,
// because the reference may be relative or absolute; scenario 1.4 resolves both
// forms in its pdfa1-url variable.
//
// The second is warning only, and the reason is a judgement call. An attachment
// carrying both a url and inline data still offers the document as a reference,
// so the sentence above does not strictly forbid it. What forbids it is
// IHE.MHD.Minimal.DocumentReference, which puts attachment.data at 0..0, and
// that is a Nictiz profile GUPZ has not adopted in its own text. Asserting it
// hard would make a Nictiz artefact normative for GUPZ. It is a warning
// instead. If GUPZ confirms that inline data is not allowed, this becomes a
// hard assert.
RuleSet: assertsDocumentByBinaryReference
* test[=].action[+].assert
  * description = "Confirm that every returned DocumentReference offers its document as a reference to a Binary resource. pdfa.md requires the data platform to offer all document references this way, so that the Retrieve Document transaction reads the Binary."
  * direction = #response
  * expression = "Bundle.entry.select(resource as DocumentReference).content.attachment.all(url.exists() and url.contains('Binary/'))"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Check that no returned DocumentReference carries its document inline in attachment.data. Assert is set to warning only because pdfa.md requires the reference but does not state in so many words that inline data is forbidden; the profile the fixtures declare, IHE.MHD.Minimal.DocumentReference, puts attachment.data at 0..0, and GUPZ has not adopted that profile in its own text."
  * direction = #response
  * expression = "Bundle.entry.select(resource as DocumentReference).content.attachment.data.exists().not()"
  * stopTestOnFail = false
  * warningOnly = true


// pdfa.md prescribes how a document reference is coded: DocumentReference.type
// carries one of six LOINC codes, context.practiceSetting one of seven Vektis
// codes, and description and attachment.title a readable title built from the
// GUPZ name of the document type, a space, and the display of the discipline.
// All three are a MUST and say what has to be there, so all three asserts are
// hard. See docs/decisions.md D-35.
//
// The practiceSetting assert matches on the code alone. pdfa.md names the
// Vektis codes but not the system they belong to, so asserting a system would
// make our choice in the fixtures normative (D-34).
//
// The title is rebuilt from the codes rather than read from the displays in the
// response, so a wrong display does not make a wrong title look right. A type
// or discipline outside the tables yields no expected title, and the assert
// fails on that document, which the two asserts before it already report.
RuleSet: assertsDocumentCoding
* test[=].action[+].assert
  * description = "Confirm that every returned DocumentReference codes its type with one of the six LOINC codes pdfa.md prescribes: 18776-5, 51847-2, 51848-0, 86530-3, 34133-9 or 11488-4."
  * direction = #response
  * expression = "Bundle.entry.select(resource as DocumentReference).all(type.coding.where(system = 'http://loinc.org' and code in ('18776-5' | '51847-2' | '51848-0' | '86530-3' | '34133-9' | '11488-4')).exists())"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that every returned DocumentReference codes context.practiceSetting with one of the seven Vektis codes pdfa.md prescribes: 0400, 0500, 0725, 2405, 8805, 4405 or 9013."
  * direction = #response
  * expression = "Bundle.entry.select(resource as DocumentReference).all(context.practiceSetting.coding.where(code in ('0400' | '0500' | '0725' | '2405' | '8805' | '4405' | '9013')).exists())"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that every returned DocumentReference carries the readable title pdfa.md prescribes, in description and in every attachment.title: the GUPZ name of the document type, a space, and the display of the practiceSetting, for example 'Behandelplan Fysiotherapeuten, niet nader gespecificeerd'."
  * direction = #response
  * expression = "Bundle.entry.select(resource as DocumentReference).all(description = (iif(type.coding.where(code = '18776-5').exists(), 'Behandelplan', iif(type.coding.where(code = '51847-2').exists(), 'Diagnostiekplan', iif(type.coding.where(code = '51848-0').exists(), 'Paramedische diagnose', iif(type.coding.where(code = '86530-3').exists(), 'DT-bericht', iif(type.coding.where(code = '34133-9').exists(), 'Update', iif(type.coding.where(code = '11488-4').exists(), 'Antwoord op uw vraag', '')))))) + ' ' + iif(context.practiceSetting.coding.where(code = '0400').exists(), 'Fysiotherapeuten, niet nader gespecificeerd', iif(context.practiceSetting.coding.where(code = '0500').exists(), 'Logopedisten, niet nader gespecificeerd', iif(context.practiceSetting.coding.where(code = '0725').exists(), 'Oefentherapeuten', iif(context.practiceSetting.coding.where(code = '2405').exists(), 'Diëtetiek', iif(context.practiceSetting.coding.where(code = '8805').exists(), 'Ergotherapie', iif(context.practiceSetting.coding.where(code = '4405').exists(), 'Optometrie', iif(context.practiceSetting.coding.where(code = '9013').exists(), 'Huidtherapie', '')))))))) and content.attachment.title.distinct() = description)"
  * stopTestOnFail = false
  * warningOnly = false
