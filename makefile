#
# makefile
#
# project: splitpdf
# created by funmy on 12/25/2024
#

SMALL_PDFFILE="../../pdf-files/1p-math.pdf"
BIG_PDFFILE="../../pdf-files/tulu-3.pdf"
BIG_OUTPUT_DIR="../outputs/bigpdf"

SWIFT_SPLITPDF="${HOME}/Library/Developer/Xcode/DerivedData/splitpdf-ejalcjjsbshvirexdxyodxbekvgg/Build/Products/Debug/splitpdf"
JS_SPLITPDF="node splitpdf.js"

help:
	@echo "makefile provides the following targets:"
	@echo
	@echo "rustsplitpdf: splits PDF file using RUST code"
	@echo
	@echo "pysplitpdf: splits PDF file using Python code"
	@echo
	@echo "swiftsplitpdf: splits PDF file using Swift code"
	@echo
	@echo "jssplitpdf: splits PDF file using JavaScript code"
	@echo

jssplitpdf:
	pushd js-splitpdf
	${JS_SPLITPDF} ${BIG_PDFFILE} ${BIG_OUTPUT_DIR} multiple
	popd

swiftsplitpdf:
	pushd swift-splitpdf
	${SWIFT_SPLITPDF} ${BIG_PDFFILE} ${BIG_OUTPUT_DIR} multiple
	popd

rustsplitpdf:
	pushd rust-splitpdf
	cargo build
	./target/debug/splitpdf -p ${BIG_PDFFILE} -o ${BIG_OUTPUT_DIR}
	popd

pysplitpdf:

	pushd py-splitpdf
	for i (2 4 8 12 16); \
		do echo "set threads to $i"; \
		python splitpdf.py -p ${BIG_PDFFILE} -o ${BIG_OUTPUT_DIR}$i -m $i; \
		echo "------"; 
	done
	popd