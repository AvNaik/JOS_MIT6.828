#ifndef JOS_INC_ELF_H
#define JOS_INC_ELF_H

#define ELF_MAGIC 0x464C457FU	/* "\x7FELF" in little endian */

struct Elf {
	uint32_t e_magic;	// must equal ELF_MAGIC
	uint8_t e_elf[12]; 
	uint16_t e_type;	//Type of Object File
	uint16_t e_machine;	//Specifies target ISA
	uint32_t e_version;	//Specifes version of ELF. Set to 1 for original ELF file
	uint32_t e_entry;	//Entry point of program from which to begin execution.
	uint32_t e_phoff;	//Start address of program header table
	uint32_t e_shoff;	//Start address of section header table
	uint32_t e_flags;	//dependent on architecture
	uint16_t e_ehsize;	//size of ELF Header
	uint16_t e_phentsize;	//size of Program header table entry
	uint16_t e_phnum;		//number of entries in program header table
	uint16_t e_shentsize;	//size of Section header table entries
	uint16_t e_shnum;	//Number of Section Header table entries
	uint16_t e_shstrndx;	//Index of Section header table which contains names of different setions
};

struct Proghdr {
	uint32_t p_type;	//Identifies type of segment to be loaded into memory only if the type is PT_LOAD
	uint32_t p_offset;	//Offset of the segment in the file image.
	uint32_t p_va;	//Virtual address of the segment in memory
	uint32_t p_pa;	//if relevant physical address the segment should be loaded into
	uint32_t p_filesz;	//size of the segment in bytes on file
	uint32_t p_memsz;	//size of the segment in bytes in memory.
	uint32_t p_flags;	
	uint32_t p_align;	//Specifies alignment. Should be an integral of two. 0 or 1 specifies no alignment.
};

struct Secthdr {
	uint32_t sh_name;
	uint32_t sh_type;
	uint32_t sh_flags;
	uint32_t sh_addr;
	uint32_t sh_offset;
	uint32_t sh_size;
	uint32_t sh_link;
	uint32_t sh_info;
	uint32_t sh_addralign;
	uint32_t sh_entsize;
};

// Values for Proghdr::p_type
#define ELF_PROG_LOAD		1

// Flag bits for Proghdr::p_flags
#define ELF_PROG_FLAG_EXEC	1
#define ELF_PROG_FLAG_WRITE	2
#define ELF_PROG_FLAG_READ	4

// Values for Secthdr::sh_type
#define ELF_SHT_NULL		0
#define ELF_SHT_PROGBITS	1
#define ELF_SHT_SYMTAB		2
#define ELF_SHT_STRTAB		3

// Values for Secthdr::sh_name
#define ELF_SHN_UNDEF		0

#endif /* !JOS_INC_ELF_H */
