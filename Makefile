
MYSQL_CONFIG := $(shell /bin/sh -c "which mysql_config 2>/dev/null || which mysql_config5 2>/dev/null")
MYSQL_CFLAGS := $(shell $(MYSQL_CONFIG) --cflags)
MYSQL_LIBS   := $(shell $(MYSQL_CONFIG) --libs_r)

OPTIM = -O2
#OPTIM = -g
CFLAGS = $(MYSQL_CFLAGS) -fPIC $(OPTIM) -Wall
LIBS = $(MYSQL_LIBS)

CC = gcc

SOURCES := $(wildcard *.c)
OBJECTS := $(SOURCES:.c=.o)

MYSQL_USER = philip
MYSQL_PASS = philip

UNAME := $(shell /bin/sh -c "uname | tr A-Z a-z")
ifeq ($(UNAME),darwin)
 SOFLAGS = -shared -bundle
 SOSUFFIX = bundle
# DEST = /opt/local/lib
 DEST = /var/root/lib
 MYSQL = /opt/local/bin/mysql5
else
 SOFLAGS = -Wl,-soname,$@
 SOSUFFIX = so
 DEST = /usr/local/lib
 MYSQL = mysql
endif

.PHONY: all
all: bitwise.$(SOSUFFIX)

clean:
	rm -f *.o *.$(SOSUFFIX)

uninstall:
	sudo ./uninstall_funcs.sh MYSQL=$(MYSQL) SONAME=bitwise.$(SOSUFFIX)

install: all uninstall
	sudo mkdir -p $(DEST)
	sudo cp bitwise.$(SOSUFFIX) $(DEST)
	sudo chmod 644 $(DEST)/bitwise.$(SOSUFFIX)
	sudo ./install_funcs.sh MYSQL=$(MYSQL) SONAME=bitwise.$(SOSUFFIX)

test:
	./test.rb -u "$(MYSQL_USER)" -p "$(MYSQL_PASS)"

bitwise.$(SOSUFFIX): $(OBJECTS)
	gcc $(SOFLAGS) -o $@ $(OBJECTS)

