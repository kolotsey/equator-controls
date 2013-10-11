# Copyright 2011 Sergey Kolotsey.
#
# This file is part of equator-controls library.
#
# equator-controls is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# equator-controls is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public Licenise
# along with libexpression. If not, see <http://www.gnu.org/licenses/>.


# Change if your flex is located somewhere else
FLEXDIR=/opt/flex


INCLUDECLASS=ws.equator.controls.GUI
EXT_LIBRARIES=$(FLEXDIR)/frameworks/libs/player/11.1/playerglobal.swc,$(FLEXDIR)/frameworks/libs/textLayout.swc,$(FLEXDIR)/frameworks/libs/textLayout.swc,$(FLEXDIR)/frameworks/libs/osmf.swc,$(FLEXDIR)/frameworks/libs/authoringsupport.swc,$(FLEXDIR)/frameworks/libs/core.swc

TARGET=equator-controls.swc
SRCDIR=./src
SOURCES=$(shell find $(SRCDIR) 2>/dev/null |grep '\.as$$' 2>/dev/null)
CFLAGS= \
	-compiler.source-path=$(SRCDIR) \
	-include-classes=$(INCLUDECLASS) \
	-strict=true \
	-show-actionscript-warnings=true \
	-show-binding-warnings=true \
	-show-invalid-css-property-warnings=true \
	-show-shadowed-device-font-warnings=true \
	-show-unused-type-selector-warnings=true \
	-debug=false \
	-omit-trace-statements=true \
	-optimize=true \
	-swf-version=11 \
	-target-player=11.1 \
	-external-library-path+=$(EXT_LIBRARIES)

all:$(TARGET)

$(TARGET):$(SOURCES) Makefile
	$(FLEXDIR)/bin/compc $(CFLAGS) -output $@



TEST_TARGET=test.swf
TEST_SRCDIR=./test
TEST_SOURCES=$(shell find $(TEST_SRCDIR) 2>/dev/null |grep '\.as$$' 2>/dev/null)
TEST_CFLAGS=\
	-static-link-runtime-shared-libraries=true \
	-compiler.debug \
	-omit-trace-statements=false \
	-default-size=320,240 \
	-default-frame-rate=20 \
	-library-path+=$(FLEXDIR)/frameworks/libs/ \
	-library-path+=$(TARGET) \
	-swf-version=11 \
	-target-player=11.1

test:$(TEST_TARGET)
	flashplayer $(TEST_TARGET)

$(TEST_TARGET): $(TARGET) $(TEST_SOURCES) Makefile
	$(FLEXDIR)/bin/mxmlc $(TEST_CFLAGS) -o $@ -source-path=$(TEST_SRCDIR) $(TEST_SRCDIR)/Test.as

clean:
	rm -f $(TARGET) $(TEST_TARGET)
