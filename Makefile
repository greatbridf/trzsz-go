BIN_DIR := ./bin
BIN_DST := /usr/bin
VERSION := 1.2.0
RELEASE := 1
TARNAME := trzsz-$(VERSION)-$(RELEASE)
TAREXT  := tar.gz
TARBALL := $(TARNAME).$(TAREXT)
excludes := bin/* dist/* .git/* .github/* .*.swp

ifdef GOOS
	ifeq (${GOOS}, windows)
		WIN_TARGET := True
	endif
else
	ifeq (${OS}, Windows_NT)
		WIN_TARGET := True
	endif
endif

ifdef WIN_TARGET
	TRZ := trz.exe
	TSZ := tsz.exe
	TRZSZ := trzsz.exe
else
	TRZ := trz
	TSZ := tsz
	TRZSZ := trzsz
endif

ifeq (${OS}, Windows_NT)
	RM := PowerShell -Command Remove-Item -Force
	GO_TEST := go test
else
	RM := rm -f
	GO_TEST := ${shell basename `which gotest 2>/dev/null` 2>/dev/null || echo go test}
endif

.PHONY: all clean test install tarball dist

all: ${BIN_DIR}/${TRZ} ${BIN_DIR}/${TSZ} ${BIN_DIR}/${TRZSZ}

${BIN_DIR}/${TRZ}: $(wildcard ./cmd/trz/*.go ./trzsz/*.go) go.mod go.sum
	go build -o ${BIN_DIR}/ ./cmd/trz

${BIN_DIR}/${TSZ}: $(wildcard ./cmd/tsz/*.go ./trzsz/*.go) go.mod go.sum
	go build -o ${BIN_DIR}/ ./cmd/tsz

${BIN_DIR}/${TRZSZ}: $(wildcard ./cmd/trzsz/*.go ./trzsz/*.go) go.mod go.sum
	go build -o ${BIN_DIR}/ ./cmd/trzsz

clean:
	$(foreach f, $(wildcard ${BIN_DIR}/*), $(RM) $(f);)

test:
	${GO_TEST} -v -count=1 ./trzsz

install: all
ifdef WIN_TARGET
	@echo install target is not supported for Windows
else
	@mkdir -p ${DESTDIR}${BIN_DST}
	cp ${BIN_DIR}/trz ${DESTDIR}${BIN_DST}/
	cp ${BIN_DIR}/tsz ${DESTDIR}${BIN_DST}/
	cp ${BIN_DIR}/trzsz ${DESTDIR}${BIN_DST}/
endif

dist/$(TARBALL):
	mkdir -p dist
	git archive HEAD --format=$(TAREXT) --prefix=$(TARNAME)/ --output $@

define DO_RPMBUILD
@echo "=== RPMBULID ==="
rpmbuild \
	--define '_topdir $(CURDIR)/dist' \
	--define '_builddir $(CURDIR)/dist/build' \
	--define '_rpmdir $(CURDIR)/dist/rpm' \
	--define '_sourcedir $(CURDIR)/dist' \
	--define '_specdir $(CURDIR)/dist' \
	--define '_srcrpmdir $(CURDIR)/dist' \
	--define '_buildrootdir $(CURDIR)/dist/buildroot' \
	--define 'debug_package %{nil}' \
	--define 'tarname $(TARNAME)' \
	--define 'tarball $(TARBALL)' \
	$(1)
endef

dist: dist/$(TARBALL)
	$(call DO_RPMBUILD,-bb --nodeps build.spec)
