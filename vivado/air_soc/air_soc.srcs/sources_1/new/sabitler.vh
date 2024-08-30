//------Sentez Parametreleri------
`define VCU108
//`define NEXYS
// `define SPIKE_DIFF
// `define LOG_COMMITS
// `define OPENLANE
`define USE_MUL_PIPE

//-----------Diger----------------
`define HIGH 1'b1
`define LOW  1'b0

`define VERI_BIT        32
`define VERI_BYTE       (`VERI_BIT / 8)
`define BUYRUK_BIT      32
`define PS_BIT          32
`define N_YAZMAC        32
`define YAZMAC_BIT      5
`define CSR_ADRES_BIT   12

// `define SPI_SEAMLESS    
`define SPI_IS_MSB      1'b1

// !!! DDB <> Yazmac Oku ve DDB <> Geri Yaz icin assert(VERI_BIT == MXLEN) !!!
`define XLEN            32
`define MXLEN           32

`define TL_OP_GET          4
`define TL_OP_ACK          0
`define TL_OP_ACK_DATA     1
`define TL_OP_PUT_FULL     0
`define TL_OP_PUT_PART     1

`define TL_A_MASK       16:9
`define TL_A_PARAM      8:7
`define TL_A_SRC        6
`define TL_A_SZ         5:3
`define TL_A_OP         2:0

`define TL_D_SIZE       10:8
`define TL_D_PARAM      7:6
`define TL_D_SRC        5
`define TL_D_SZ         4:3
`define TL_D_OP         2:0

`define TL_A_BITS       27
`define TL_D_BITS       11

`define TL_REQ_A_GET    17'b11111111_00_0_101_100
`define TL_REQ_A_PUTF   17'b11111111_00_0_101_000
`define TL_REQ_A_PUTP   17'b11111111_00_0_101_001

//-----------Bellek---------------
`define ADRES_BIT           32
`define BELLEK_BASLANGIC    32'h4000_0000
`define BELLEK_BOYUT        32'h0004_0000

//-----------Adres Aralıkları-----------
`define UART_BASE_ADDR      32'h2000_0000
`define UART_MASK_ADDR      32'h0000_000f
`define SPI_BASE_ADDR       32'h2001_0000
`define SPI_MASK_ADDR       32'h0000_00ff
`define RAM_BASE_ADDR       32'h4000_0000
`define RAM_BASE            32'h4000_0000
`define RAM_MASK_ADDR       32'h0007_ffff
`define TIMER_BASE_ADDR     32'h3000_0000
`define TIMER_MASK_ADDR     32'h0000_000f
`define PWM_BASE_ADDR       32'h2002_0000
`define PWM_MASK_ADDR       32'h0000_00ff

//-------Önbellek Denetleyiciler----------
`define L1_BLOK_BIT 32    
`define L1B_SATIR   256
`define L1B_YOL     2  
`define L1V_SATIR   256
`define L1V_YOL     2
`define L1_BOYUT    (`L1_BLOK_BIT * `L1B_SATIR * `L1B_YOL) + (`L1_BLOK_BIT * `L1V_SATIR * `L1V_YOL) // Teknofest 2022-2023 icin 4KB olmali
`define L1_ONBELLEK_GECIKME 1 // Denetleyici gecikmesi degil, SRAM/BRAM gecikmesi

`define ADRES_OZEL_DAGITIM
`define ADRES_BUYRUK_OZEL_BIT 0
`define ADRES_VERI_OZEL_BIT   0
`define ADRES_BYTE_BIT      2 // Veriyi byte adreslemek icin gereken bit
`define ADRES_BYTE_OFFSET   0 // ADRES_BYTE ilk bitine erismek icin gereken kaydirma
`define ADRES_SATIR_BIT     8 // Satirlari indexlemek icin gereken bit
`define ADRES_SATIR_OFFSET  (`ADRES_BYTE_OFFSET + `ADRES_BYTE_BIT) // ADRES_SATIR ilk bitine erismek icin gereken kaydirma
`define ADRES_ETIKET_BIT    (`ADRES_BIT - `ADRES_SATIR_BIT - `ADRES_BYTE_BIT) // Adresin kalan kismi
`define ADRES_ETIKET_OFFSET (`ADRES_SATIR_OFFSET + `ADRES_SATIR_BIT) // Adresin kalan kismi

`define L1_BLOK_BYTE (`L1_BLOK_BIT / 8)

// ----Yardımcı Tanımlamalar----
`define ALL_ONES_256        256'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF
`define ALL_ONES_128        128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF
`define ALL_ONES_64          64'hFFFF_FFFF_FFFF_FFFF
`define ALL_ONES_32          32'hFFFF_FFFF

// ----Maskeleme İçin Yardımcı Tanımlar----
`define NOP_MASKE           4'b0000  // Böyle mi olmalı ?

`define BYTE_MAKSE_0        4'b0001
`define BYTE_MAKSE_1        4'b0010
`define BYTE_MAKSE_2        4'b0100
`define BYTE_MAKSE_3        4'b1000

`define HALF_WORD_MASKE_0   4'b0011
`define HALF_WORD_MASKE_1   4'b0110  // Bu erişimi yapabildiğiniz varsaydık
`define HALF_WORD_MASKE_2   4'b1100

`define WORD_MASKE          4'b1111

// ----Yapay Zeka Birimi Tanimlamalar----
`define N_CNN_YAZMAC        16
`define CNN_YAZMAC_BIT      $clog2(`N_CNN_YAZMAC + 1)

// ----SPI Denetleyici Tanimlamalar----
`define SPI_CTRL_REG        8'h00
`define SPI_STATUS_REG      8'h04
`define SPI_RDATA_REG       8'h08
`define SPI_WDATA_REG       8'h0c
`define SPI_CMD_REG         8'h10
`define SPI_TXN_SIZE        8

// ----UART Denetleyici Tanimlamalar----
`define UART_CTRL_REG        8'h00
`define UART_STATUS_REG      8'h04
`define UART_RDATA_REG       8'h08
`define UART_WDATA_REG       8'h0c
`define UART_TXN_SIZE        8


// ----PWM Denetleyici Tanimlamalar----
`define PWM_CTRL_1_REG       8'h00
`define PWM_CTRL_2_REG       8'h04
`define PWM_PERIOD_1_REG     8'h08
`define PWM_PERIOD_2_REG     8'h0c
`define PWM_THRSLD_1_1_REG   8'h10
`define PWM_THRSLD_1_2_REG   8'h14
`define PWM_THRSLD_2_1_REG   8'h18
`define PWM_THRSLD_2_2_REG   8'h1c
`define PWM_STEP_1_REG       8'h20
`define PWM_STEP_2_REG       8'h24
`define PWM_WRT_1_REG        8'h28
`define PWM_WRT_2_REG        8'h2c

//----Dallanma Öngörücü Tanimlamalar----
`define BTB_SATIR_SAYISI         32
`define BTB_PS_BIT               5
`define BTB_SATIR_BOYUT          (`PS_BIT - `BTB_PS_BIT) + 1 + `PS_BIT
`define BHT_SATIR_SAYISI         32
`define BHT_PS_BIT               5
`define DALLANMA_TAHMIN_BIT      2 // ilerde çift kutuplu yapılabilir
`define BHT_SATIR_BOYUT          (`PS_BIT - `BHT_PS_BIT) + `DALLANMA_TAHMIN_BIT
`define GENEL_GECMIS_YAZMACI_BIT 5
`define BTB_VALID_BITI           `BTB_SATIR_BOYUT-1 // en anlamlı biti
`define GGY_SAYAC_BIT            3

// Buyruk Bilgisi
`define UOP_VALID_BIT       1
`define UOP_VALID_PTR       0
`define UOP_VALID           0

`define UOP_RVC_BIT         1
`define UOP_RVC_PTR         `UOP_VALID_PTR + `UOP_VALID_BIT
`define UOP_RVC             `UOP_RVC_PTR +: `UOP_RVC_BIT

`define UOP_PC_BIT          32
`define UOP_PC_PTR          `UOP_RVC_PTR + `UOP_RVC_BIT
`define UOP_PC              `UOP_PC_PTR +: `UOP_PC_BIT

`define UOP_TAG_BIT         4
`define UOP_TAG_PTR         `UOP_PC_PTR + `UOP_PC_BIT
`define UOP_TAG             `UOP_TAG_PTR +: `UOP_TAG_BIT

// RD yazmac adresi
`define UOP_RD_ADDR_BIT     5
`define UOP_RD_ADDR_PTR     `UOP_TAG_PTR + `UOP_TAG_BIT
`define UOP_RD_ADDR         `UOP_RD_ADDR_PTR +: `UOP_RD_ADDR_BIT

// RD'ye yazma yapilacagini belirten flag
`define UOP_RD_ALLOC_BIT    1
`define UOP_RD_ALLOC_PTR    `UOP_RD_ADDR_PTR + `UOP_RD_ADDR_BIT
`define UOP_RD_ALLOC        `UOP_RD_ALLOC_PTR +: `UOP_RD_ALLOC_BIT

// RS2'den okuma yapilacagini belirten flag
`define UOP_RS2_EN_BIT      1
`define UOP_RS2_EN_PTR      (`UOP_RD_ALLOC_PTR + `UOP_RD_ALLOC_BIT)
`define UOP_RS2_EN          `UOP_RS2_EN_PTR +: `UOP_RS2_EN_BIT

// RS1'den okuma yapilacagini belirten flag
`define UOP_RS1_EN_BIT      1
`define UOP_RS1_EN_PTR      (`UOP_RS2_EN_PTR + `UOP_RS2_EN_BIT)
`define UOP_RS1_EN          `UOP_RS1_EN_PTR +: `UOP_RS1_EN_BIT

// Islecler (Simdilik 4 tane lazim sanirim? Islec iletmek gerekirse genisletilebilir)
`define UOP_RD_BIT          32
`define UOP_RD_PTR          (`UOP_RS1_EN_PTR + `UOP_RS1_EN_BIT)
`define UOP_RD              `UOP_RD_PTR +: `UOP_RD_BIT

`define UOP_IMM_BIT         32
`define UOP_IMM_PTR         (`UOP_RD_PTR + `UOP_RD_BIT)
`define UOP_IMM             `UOP_IMM_PTR +: `UOP_IMM_BIT

`define UOP_RS2_BIT         32
`define UOP_RS2_PTR         (`UOP_IMM_PTR + `UOP_IMM_BIT)
`define UOP_RS2             `UOP_RS2_PTR +: `UOP_RS2_BIT

`define UOP_RS1_BIT         32
`define UOP_RS1_PTR         (`UOP_RS2_PTR + `UOP_RS2_BIT)
`define UOP_RS1             `UOP_RS1_PTR +: `UOP_RS1_BIT 

`define UOP_CSR_BIT         32
`define UOP_CSR_PTR         (`UOP_RS1_PTR + `UOP_RS1_BIT)
`define UOP_CSR             `UOP_CSR_PTR +: `UOP_CSR_BIT

`define UOP_CSR_ADDR_BIT    12
`define UOP_CSR_ADDR_PTR    (`UOP_CSR_PTR + `UOP_CSR_BIT)
`define UOP_CSR_ADDR        `UOP_CSR_ADDR_PTR +: `UOP_CSR_ADDR_BIT

`define UOP_CSR_ALLOC_BIT   1
`define UOP_CSR_ALLOC_PTR   (`UOP_CSR_ADDR_PTR + `UOP_CSR_ADDR_BIT)
`define UOP_CSR_ALLOC       `UOP_CSR_ALLOC_PTR +: `UOP_CSR_ALLOC_BIT

`define UOP_CSR_EN_BIT      1
`define UOP_CSR_EN_PTR      (`UOP_CSR_ALLOC_PTR + `UOP_CSR_ALLOC_BIT)
`define UOP_CSR_EN          `UOP_CSR_EN_PTR +: `UOP_CSR_EN_BIT

// Aritmetik Mantik Birimi
`define UOP_AMB_NOP         0
`define UOP_AMB_ADD         1
`define UOP_AMB_SUB         2
`define UOP_AMB_DIV         3
`define UOP_AMB_MUL         4
`define UOP_AMB_AND         5
`define UOP_AMB_OR          6
`define UOP_AMB_XOR         7
`define UOP_AMB_SLL         8
`define UOP_AMB_SRL         9
`define UOP_AMB_SRA         10
`define UOP_AMB_SLT         11
`define UOP_AMB_SLTU        12
`define UOP_AMB_HMDST       13
`define UOP_AMB_PKG         14
`define UOP_AMB_RVRS        15
`define UOP_AMB_SLADD       16
`define UOP_AMB_CNTZ        17
`define UOP_AMB_CNTP        18
`define UOP_AMB_MULH        19
`define UOP_AMB_MULHSU      20
`define UOP_AMB_MULHU       21
`define UOP_AMB_DIVU        22
`define UOP_AMB_REM         23
`define UOP_AMB_REMU        24

`define UOP_AMB_OP_NOP      0
`define UOP_AMB_OP_RS1      1
`define UOP_AMB_OP_RS2      2
`define UOP_AMB_OP_IMM      3
`define UOP_AMB_OP_CSR      4
`define UOP_AMB_OP_PC       5

`define UOP_AMB_OP_BIT      3

// Islecler hangi veriler olmali?
`define UOP_AMB_OP2_BIT     `UOP_AMB_OP_BIT
`define UOP_AMB_OP2_PTR     (`UOP_CSR_EN_PTR + `UOP_CSR_EN_BIT)
`define UOP_AMB_OP2         `UOP_AMB_OP2_PTR +: `UOP_AMB_OP2_BIT

`define UOP_AMB_OP1_BIT     `UOP_AMB_OP_BIT
`define UOP_AMB_OP1_PTR     (`UOP_AMB_OP2_PTR + `UOP_AMB_OP2_BIT)
`define UOP_AMB_OP1         `UOP_AMB_OP1_PTR +: `UOP_AMB_OP1_BIT

`define UOP_AMB_BIT         5
`define UOP_AMB_PTR         (`UOP_AMB_OP1_PTR + `UOP_AMB_OP1_BIT)
`define UOP_AMB             `UOP_AMB_PTR +: `UOP_AMB_BIT

// Yazilacak veri secimi
`define UOP_YAZ_NOP         0
`define UOP_YAZ_AMB         1
`define UOP_YAZ_IS1         2
`define UOP_YAZ_DAL         3
`define UOP_YAZ_CSR         4
`define UOP_YAZ_BEL         5
`define UOP_YAZ_YZB         6

`define UOP_YAZ_BIT         3
`define UOP_YAZ_PTR         (`UOP_AMB_PTR + `UOP_AMB_BIT)
`define UOP_YAZ             `UOP_YAZ_PTR +: `UOP_YAZ_BIT

// Dallanma Birimi
`define UOP_DAL_NOP             0
`define UOP_DAL_BEQ             1
`define UOP_DAL_BNE             2
`define UOP_DAL_BLT             3
`define UOP_DAL_JAL             4
`define UOP_DAL_JALR            5
`define UOP_DAL_BGE             6
`define UOP_DAL_BLTU            7
`define UOP_DAL_BGEU            8
`define UOP_DAL_CJAL            9
`define UOP_DAL_CJALR           10

`define UOP_DAL_BIT             4
`define UOP_DAL_PTR             (`UOP_YAZ_PTR + `UOP_YAZ_BIT)
`define UOP_DAL                 `UOP_DAL_PTR +: `UOP_DAL_BIT

`define UOP_TAKEN_BIT           1
`define UOP_TAKEN_PTR           (`UOP_DAL_PTR + `UOP_DAL_BIT)
`define UOP_TAKEN               `UOP_TAKEN_PTR +: `UOP_TAKEN_BIT

// Bellek Islemleri
`define UOP_BEL_NOP             0
`define UOP_BEL_LW              1
`define UOP_BEL_LH              2
`define UOP_BEL_LHU             3
`define UOP_BEL_LB              4
`define UOP_BEL_LBU             5
`define UOP_BEL_SW              6
`define UOP_BEL_SH              7
`define UOP_BEL_SB              8

`define UOP_BEL_BIT             4   //seçim için kullanılacak
`define UOP_BEL_PTR             (`UOP_TAKEN_PTR + `UOP_TAKEN_BIT)
`define UOP_BEL                 `UOP_BEL_PTR +: `UOP_BEL_BIT

`define EXC_CODE_IAM            0   // Instruction Address Misaligned
`define EXC_CODE_IS             1   // Illegal Instruction
`define EXC_CODE_LAM            4   // Load Address Misaligned
`define EXC_CODE_SAM            6   // Store Address Misaligned
`define EXC_CODE_MRET           11  // Environment call from M-mode

`define EXC_CODE_BIT            5

// CSR Islemleri
`define UOP_CSR_NOP             0
`define UOP_CSR_RW              1
`define UOP_CSR_RS              2
`define UOP_CSR_RC              3
`define UOP_CSR_MRET            4

`define UOP_CSR_OP_BIT          4 // CSR_OP berbat bir isim, AMB_OP1'deki OPerand ile buradaki CSR_OPeration kisaltmasi ayristirilmali
`define UOP_CSR_OP_PTR          (`UOP_BEL_PTR + `UOP_BEL_BIT)
`define UOP_CSR_OP              `UOP_CSR_OP_PTR +: `UOP_CSR_OP_BIT

// Yapaz Zeka Birimi
`define UOP_YZB_NOP             0
`define UOP_YZB_LDX_OP1         1
`define UOP_YZB_LDX_ALL         2
`define UOP_YZB_LDW_OP1         3
`define UOP_YZB_LDW_ALL         4
`define UOP_YZB_CLRX            5
`define UOP_YZB_CLRW            6
`define UOP_YZB_RUN             7

`define UOP_YZB_BIT             4
`define UOP_YZB_PTR             (`UOP_CSR_OP_PTR + `UOP_CSR_OP_BIT)
`define UOP_YZB                 `UOP_YZB_PTR +: `UOP_YZB_BIT

`define UOP_BIT                 (`UOP_YZB_PTR + `UOP_YZB_BIT)

//!!! TODO: HER ASAMA ICIN MIKROISLEM TANIMLARI (COZ_UOP, YURUT_UOP...) YAPILMALI, BU SAYEDE UOP YAZMACLARI KUCULTULEBILIR !!!
