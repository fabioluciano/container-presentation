OUTPUTDIR = ./output/

OUTPUTSTRING = -D $(OUTPUTDIR) -a outdir=$(OUTPUTDIR)
PLATUMLSTRING = -a plantuml-config=resources/plantuml/plantuml.cfg
ROUGESTRING = -a rouge-style=pastie
REQUIRESTRING = -r asciidoctor-diagram 
PDFOPTIONS = -a allow-uri-read
REVEALJSSTRING = -a revealjsdir=https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.8.0

OUTPUTFILE_HTML = index.html
OUTPUTFILE_PDF = documentation.pdf
OUTPUTFILE_REAVELJS = presentation.html

TAG = $(shell cat ./VERSION)

all: clean prepare pdf html presentation docker_image

clean:
	sudo rm -rf $(CURDIR)/output

prepare:
	docker pull asciidoctor/docker-asciidoctor
	mkdir -p $(OUTPUTDIR) 

copy_images:
	cp -r src/resources/image/ $(OUTPUTDIR)

html: clean prepare copy_images
	docker run --rm -v $(CURDIR):/documents/ asciidoctor/docker-asciidoctor asciidoctor -q -o $(OUTPUTFILE_HTML) $(REQUIRESTRING) $(OUTPUTSTRING) $(PLATUMLSTRING) $(ROUGESTRING) src/README.adoc

pdf: clean prepare copy_images
	docker run --rm -v $(CURDIR):/documents/ asciidoctor/docker-asciidoctor asciidoctor-pdf -q -o $(OUTPUTFILE_PDF) $(REQUIRESTRING) $(OUTPUTSTRING) $(PLATUMLSTRING) $(ROUGESTRING) $(PDFOPTIONS) src/README.adoc

presentation: clean prepare copy_images
	docker run --rm -v $(CURDIR):/documents/ asciidoctor/docker-asciidoctor asciidoctor-revealjs -q -o $(OUTPUTFILE_REAVELJS) $(REQUIRESTRING) $(OUTPUTSTRING) $(PLATUMLSTRING) $(REVEALJSSTRING) src/README.adoc

docker_image:
	tar -czvf output.tar.gz -C output .
	docker build -t container-presentation:$(TAG) --build-arg DEPLOYMENT=output.tar.gz .
	rm output.tar.gz
