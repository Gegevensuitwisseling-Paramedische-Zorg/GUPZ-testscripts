// Asserts that come from open-GUPZ rather than from the imported Nictiz
// scripts. Kept in their own file so that provenance stays visible: everything
// here tests a sentence in the GUPZ specification, and nothing here was in the
// material this repository started from.


// pdfa.md requires the data platform to offer every document reference as a
// reference to a Binary resource, so that the Retrieve Document transaction
// reads the Binary. The specification is in Dutch; this is what that sentence
// says.
//
// Nothing in the imported set tests this. A platform that returns the PDF
// inline, base64 encoded in DocumentReference.content.attachment.data, passes
// every other assert in the Dataplatform set. Scenario 1.4 does read a Binary,
// but it reads whatever url the response gave it, so serving a plain http url
// gets through there as well. That is scenario 2.5, which exists precisely for
// servers that work that way; for GUPZ it is not conformant.
//
// Two asserts, deliberately of different weight.
//
// The first is hard. The requirement is a MUST in the specification, in the
// indicative that open-GUPZ uses throughout, and it says what has to be there.
// The url is matched on containing 'Binary/' rather than on starting with it,
// because the reference may be relative or absolute; scenario 1.4 resolves both
// forms in its pdfa1-url variable.
//
// The second is warning only, and that is a judgement call worth recording. An
// attachment carrying both a url and inline data still offers the document as a
// reference, so the sentence above does not strictly forbid it. What forbids it
// is IHE.MHD.Minimal.DocumentReference, which puts attachment.data at 0..0, and
// that is a Nictiz profile which GUPZ has not adopted in its own text. Asserting
// it hard would make a Nictiz artefact normative for GUPZ by the back door. So
// it is raised as a warning and the difference is named here. If GUPZ confirms
// that inline data is not allowed, this becomes a hard assert and the
// distinction disappears.
//
// Be aware of what the hard assert does to scenario 2.1 with the imported
// fixtures. The only current document of XXX_Schulte, DocumentReference
// kwalificatie4, carries a plain https url to a PDF on the Nictiz site rather
// than a Binary reference, because Nictiz built that patient for the scenario
// 2.5 flow. Under the GUPZ rule that data is not conformant, so scenario 2.1
// fails on it, and it fails on the test data and not on the platform. The fix
// is GUPZ test data, not a softer assert. See docs/scenario-selection.md.
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
