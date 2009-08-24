
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

#MYSQL_USER = philip
#MYSQL_PASS = philip
#MYSQL_DATABASE = philip

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

FUNCS = ./funcs.sh MYSQL_DATABASE=$(MYSQL_DATABASE) SONAME=bitwise.$(SOSUFFIX)

.PHONY: all sql-up sql-down uninstall install test

all: bitwise.$(SOSUFFIX)

clean:
	rm -f *.o *.$(SOSUFFIX)

sql-up:
	@$(FUNCS) up

sql-down:
	@$(FUNCS) down

uninstall-sql:
	@echo This is your MySQL root password:
	@$(FUNCS) down | $(MYSQL) -u root -p -D $(MYSQL_DATABASE)

install-module: all
	mkdir -p $(DEST)
	cp bitwise.$(SOSUFFIX) $(DEST)
	chmod 644 $(DEST)/bitwise.$(SOSUFFIX)

install-sql: all
	@echo This is your MySQL root password:
	@$(FUNCS) up | $(MYSQL) -u root -p -D $(MYSQL_DATABASE)

test:
	./test.rb -u "$(MYSQL_USER)" -p "$(MYSQL_PASS)" -d $(MYSQL_DATABASE)

bitwise.$(SOSUFFIX): $(OBJECTS)
	gcc $(SOFLAGS) -o $@ $(OBJECTS)

