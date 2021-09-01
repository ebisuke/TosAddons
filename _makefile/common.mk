IPF = ipf
COMPRESSION_LEVEL=9
MAKEFILE_RELATIVE_DIR = ../_makefile/
TREEOFSAVIOR_DATA_DIR= ~/E/TosData/
EMOJI=📖
SRCDIR=src
OBJDIR=obj
BINDIR=bin
#PATCH=322566
#VERSION=nothing
#NAME=undefined
.DEFAULT_GOAL := generateipf

IPFPATTERN_WITH_EMOJI=__$(NAME)-$(EMOJI)-v*.ipf	
IPFNAME_WITH_EMOJI=__$(NAME)-$(EMOJI)-v$(VERSION).ipf	
IPFNAME_WITHOUT_EMOJI=$(NAME)-v$(VERSION).ipf 	

FORCE:
.PHONY: clean generateipf uninstall deploy install

clean: 
	@echo clean
	rm -rf $(OBJDIR) | true
	rm -rf $(BINDIR) | true
$(BINDIR)/$(IPFNAME_WITHOUT_EMOJI):generateipf
	$(generateipf)
generateipf: 
	@echo generateipf
	rm -rf $(OBJDIR) | true
	rm -rf $(BINDIR) | true
	mkdir $(OBJDIR) | true
	mkdir $(BINDIR) | true
	cp -r src/* obj/
ifdef PATCH
	$(IPF) -c $(COMPRESSION_LEVEL) -b $(PATCH) -r $(PATCH) $(BINDIR)/$(IPFNAME_WITHOUT_EMOJI) $(OBJDIR)
else
	$(IPF) -c $(COMPRESSION_LEVEL) $(BINDIR)/$(IPFNAME_WITHOUT_EMOJI) $(OBJDIR)
endif
	cp $(BINDIR)/$(IPFNAME_WITHOUT_EMOJI) $(BINDIR)/$(IPFNAME_WITH_EMOJI)
install: $(BINDIR)/$(IPFNAME_WITHOUT_EMOJI)
	$(uninstall)
	@echo install
	cp -f $(BINDIR)/$(IPFNAME_WITHOUT_EMOJI) $(TREEOFSAVIOR_DATA_DIR)/$(IPFNAME_WITH_EMOJI)
uninstall: $(TREEOFSAVIOR_DATA_DIR)/$(IPFPATTERN_WITH_EMOJI)
	@echo uninstall
	rm -v $(TREEOFSAVIOR_DATA_DIR)/$(IPFPATTERN_WITH_EMOJI)
