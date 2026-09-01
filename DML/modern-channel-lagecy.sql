CREATE TABLE dbo.balap_jasa_pemasaran_setting
	(
	id          INT IDENTITY NOT NULL,
	terminal_id VARCHAR (30) NOT NULL,
	type        INT NOT NULL,
	percentage  DECIMAL (10, 2) NULL,
	start_date  DATE NOT NULL,
	end_date    DATE NOT NULL,
	status      INT DEFAULT ((1)) NOT NULL,
	created_by  VARCHAR (20) NULL,
	created_at  DATETIME NULL,
	updated_by  VARCHAR (20) NULL,
	updated_at  DATETIME NULL,
	PRIMARY KEY (id)
	)
GO


CREATE TABLE dbo.balap_promo_setting
	(
	id           INT IDENTITY NOT NULL,
	product_code VARCHAR (20) NOT NULL,
	promo        INT NULL,
	start_date   DATE NOT NULL,
	end_date     DATE NOT NULL,
	status       INT DEFAULT ((1)) NOT NULL,
	created_by   VARCHAR (20) NULL,
	created_at   DATETIME NULL,
	updated_by   VARCHAR (20) NULL,
	updated_at   DATETIME NULL,
	PRIMARY KEY (id)
	)
GO

CREATE TABLE dbo.mutasi_transaksi_daily
	(
	tanggal         DATE NULL,
	namaSuplier     VARCHAR (50) NULL,
	namaSubSupplier VARCHAR (50) NULL,
	idReseller      VARCHAR (20) NULL,
	namaReseller    VARCHAR (100) NULL,
	namaOperator    VARCHAR (100) NULL,
	kodeProduct     VARCHAR (20) NULL,
	namaProduct     VARCHAR (100) NULL,
	denom           INT NULL,
	hargaBeli       FLOAT NULL,
	hargaJual       FLOAT NULL,
	discount        FLOAT NULL,
	dat             FLOAT NULL,
	arAp            FLOAT NULL,
	netto           FLOAT NULL,
	feeSwitching    INT NULL,
	nettSwitching   INT NULL,
	qty             INT NULL,
	margin          INT NULL,
	hargaJualSakala FLOAT NULL,
	fee             FLOAT NULL,
	feeDpp          FLOAT NULL,
	transStatus     VARCHAR (20) NULL,
	idTerminal      VARCHAR (20) NULL,
	namaTerminal    VARCHAR (50) NULL,
	sales           FLOAT NULL,
	cogs            FLOAT NULL,
	marginSales     INT NULL,
	feeSupplier     FLOAT NULL
	)
GO


CREATE TABLE dbo.tirs_areadomisili
	(
	idareadomisili   INT NOT NULL,
	namaareadomisili VARCHAR (100) NULL
	)
GO

CREATE TABLE dbo.tirs_front_discount
	(
	idterminal    INT NOT NULL,
	discount      MONEY NOT NULL,
	is_percentage TINYINT NOT NULL,
	after_trx     MONEY CONSTRAINT DF_tirs_front_discount_after_trx DEFAULT ((0)) NOT NULL,
	kodeproduk    VARCHAR (20) NOT NULL,
	tanggalawal   DATE NOT NULL,
	tanggalakhir  DATE NULL,
	CONSTRAINT PK_tirs_front_discount PRIMARY KEY (idterminal, kodeproduk, tanggalawal)
	)
GO

CREATE TABLE dbo.tirs_kategori_operator  --> perlu synch/pindah data dari MySQL ke postgre
	(
	idoperator         INT NOT NULL,
	idkategorioperator TINYINT NOT NULL,
	namakategori       VARCHAR (50) NULL,
	namaprovider       VARCHAR (50) NULL
	)


CREATE TABLE dbo.tirs_office_needs
	(
	nomor         VARCHAR (20) NOT NULL,
	warehouse_id  VARCHAR (4) NOT NULL,
	prosentase_ga INT NOT NULL,
	prosentase_sd INT NOT NULL,
	type_ledger   INT NOT NULL,
	CONSTRAINT PK_tirs_office_needs PRIMARY KEY (nomor)
	)
GO

CREATE TABLE dbo.tirs_price_fee
	(
	idreseller   VARCHAR (16) NOT NULL,
	kodeproduk   VARCHAR (16) NOT NULL,
	hargajual    FLOAT NULL,
	mdr          FLOAT NULL,
	tanggalawal  DATE CONSTRAINT DF_tirs_price_fee DEFAULT (getdate()) NOT NULL,
	tanggalakhir DATE NULL,
	CONSTRAINT PK_tirs_price_fee PRIMARY KEY (idreseller, kodeproduk, tanggalawal)
	)
GO

CREATE TABLE dbo.tirs_price_fee_temp
	(
	idreseller   VARCHAR (16) NOT NULL,
	kodeproduk   VARCHAR (16) NOT NULL,
	hargajual    FLOAT NULL,
	mdr          FLOAT NULL,
	tanggalawal  DATETIME CONSTRAINT DF_tirs_price_fee_temp DEFAULT (getdate()) NOT NULL,
	tanggalakhir DATETIME NULL,
	CONSTRAINT PK_tirs_price_fee_temp PRIMARY KEY (idreseller, kodeproduk, tanggalawal)
	)
GO

CREATE TABLE dbo.tirs_price_omni
	(
	idreseller       VARCHAR (16) NOT NULL,
	kodeproduk       VARCHAR (16) NOT NULL,
	hargamin         FLOAT NOT NULL,
	hargamax         FLOAT NOT NULL,
	discountreseller FLOAT NOT NULL,
	discountaftertrx FLOAT NOT NULL,
	tanggalawal      DATE NOT NULL,
	tanggalakhir     DATE NULL,
	is_percentage    TINYINT NOT NULL,
	CONSTRAINT PK_tirs_price_omni PRIMARY KEY (idreseller, kodeproduk, hargamin, tanggalawal)
	)
GO

CREATE TABLE dbo.tirs_respon_gagal --> perlu synch/pindah data dari MySQL ke postgre
	(
	idterminal INT NOT NULL,
	kata       VARCHAR (100) NOT NULL,
	jawaban    VARCHAR (100) NULL,
	rc         VARCHAR (10) NULL
	)
GO

CREATE TABLE dbo.tirs_Saldo_Alokasi
	(
	IdAlokasi            VARCHAR (30) NOT NULL,
	Tgl                  DATETIME NOT NULL,
	IdSubSuplier         INT NOT NULL,
	strPurchaseInvoiceID VARCHAR (30) NULL,
	strPurchaseOrderID   VARCHAR (30) NULL,
	Notes                VARCHAR (150) NULL,
	Status               SMALLINT CONSTRAINT DF__tirs_Sald__Statu__4A6E022D DEFAULT ((0)) NOT NULL,
	byteTypeAlokasi      TINYINT CONSTRAINT DF_tirs_Saldo_Alokasi_byteTypeAlokasi DEFAULT ((1)) NULL,
	bolPosted            BIT CONSTRAINT DF_tirs_Saldo_Alokasi_bolPosted DEFAULT ((0)) NOT NULL,
	strPostedBy          VARCHAR (50) NULL,
	dtmPostedDate        DATETIME NULL,
	Inputdate            DATETIME NULL,
	Lastupdate           DATETIME NULL,
	LastUpdatedBy        VARCHAR (50) NULL,
	CONSTRAINT PK_tirs_Saldo_Alokasi PRIMARY KEY (IdAlokasi)
	)
GO

CREATE TABLE dbo.tirs_Saldo_AlokasiDetail
	(
	IdAlokasi VARCHAR (30) NOT NULL,
	Satuan    VARCHAR (15) NOT NULL,
	Qty       NUMERIC (18) NULL,
	Nominal   NUMERIC (18) NULL,
	CONSTRAINT PK_tirs_Saldo_AlokasiDetail PRIMARY KEY (IdAlokasi, Satuan)
	)
GO

CREATE TABLE dbo.tirs_Satuan
	(
	Satuan     VARCHAR (15) NOT NULL,
	Keterangan VARCHAR (15) NOT NULL,
	CONSTRAINT PK_tirs_Satuan PRIMARY KEY (Satuan)
	)
GO

CREATE TABLE dbo.tirs_Suplier_SaldoHarian
	(
	IdTransaksi       VARCHAR (30) NOT NULL,
	Tgl               DATETIME NOT NULL,
	Notes             VARCHAR (150) NULL,
	IdSubSuplier      INT NOT NULL,
	JenisTransaksi    VARCHAR (15) NOT NULL,
	Satuan            VARCHAR (15) NOT NULL,
	monOriginalAmount NUMERIC (20, 4) NOT NULL,
	monDebit          NUMERIC (20, 4) NOT NULL,
	monCredit         NUMERIC (20, 4) NOT NULL,
	CONSTRAINT PK_tirs_Suplier_SaldoHarian PRIMARY KEY (IdTransaksi)
	)
GO

CREATE TABLE dbo.tirs_Suplier_Sub --> perlu di split menjadi table tirs_Suplier_Sub_Ledger
	(
	IdSubSuplier                  INT NOT NULL,
	NamaSubSuplier                VARCHAR (100) NOT NULL,
	IdSuplier                     INT NOT NULL,
	FormatNoAlokasi               VARCHAR (30) CONSTRAINT DF_tirs_Suplier_Sub_FormatNumber DEFAULT (' ') NOT NULL,
	LedgerID_Debet                VARCHAR (30) NULL,
	LedgerID_Credit               VARCHAR (30) NULL,
	LedgerID_VAT                  VARCHAR (30) NULL,
	LedgerID_PrepaidTax           VARCHAR (30) NULL,
	LedgerID_Other                VARCHAR (30) NULL,
	strLedgerIDForAR              VARCHAR (30) NULL,
	strLedgerIDForPurchase        VARCHAR (30) NULL,
	strLedgerIDForSales           VARCHAR (30) NULL,
	strLedgerIDForCOGS            VARCHAR (30) NULL,
	strLedgerIDForPurchaseDisc    VARCHAR (30) NULL,
	strLedgerIDForCOGSFee         VARCHAR (30) NULL,
	strLedgerIDForAccruedExpenses VARCHAR (30) NULL,
	Flag_PPOB                     VARCHAR (1) CONSTRAINT DF_tirs_Suplier_Sub_Flag_PPOB DEFAULT ((0)) NOT NULL,
	strLedgerIDForAdvancePayment  VARCHAR (30) NULL,
	CONSTRAINT PK_tirs_Suplier_Sub PRIMARY KEY (IdSubSuplier)
	)
GO

CREATE TABLE dbo.tirs_Suplier_Sub_SaldoHarian
	(
	IdSubSuplier INT NOT NULL,
	Tgl          DATETIME NOT NULL,
	Nominal      MONEY CONSTRAINT DF_tirs_Suplier_Sub_SaldoHarian_Nominal DEFAULT ((0)) NOT NULL,
	CONSTRAINT PK_tirs_Suplier_Sub_SaldoHarian PRIMARY KEY (IdSubSuplier, Tgl)
	)
GO

CREATE TABLE dbo.tirs_Suplier_Sub_Terminal
	(
	IdTerminal   INT NOT NULL,
	IdSubSuplier INT NOT NULL,
	CONSTRAINT PK_tirs_Suplier_Sub_Terminal PRIMARY KEY (IdTerminal)
	)
GO

CREATE TABLE dbo.tirs_tarif_ppob
	(
	idreseller            VARCHAR (16) NOT NULL,
	kodeproduk            VARCHAR (16) NOT NULL,
	hargadasar            FLOAT NULL,
	biayaadmin            FLOAT NULL,
	feereseller           FLOAT NULL,
	feesakala             FLOAT NULL,
	ppnreseller           FLOAT NULL,
	pphreseller           FLOAT NULL,
	feeresellerincludeppn FLOAT NULL,
	tanggalawal           DATETIME CONSTRAINT DF_tirs_tarif_ppob_tanggalawal DEFAULT (getdate()) NOT NULL,
	tanggalakhir          DATETIME NULL,
	upload_feereseller    FLOAT NULL,
	upload_ppnreseller    FLOAT NULL,
	upload_pphreseller    FLOAT NULL,
	CONSTRAINT PK_tirs_tarif_ppob PRIMARY KEY (idreseller, kodeproduk, tanggalawal)
	)
GO

CREATE TABLE dbo.tirs_terminal_produk_fee
	(
	idterminal   INT NOT NULL,
	kodeproduk   VARCHAR (20) NOT NULL,
	fee          MONEY NOT NULL,
	tanggalawal  DATE NOT NULL,
	tanggalakhir DATE NULL,
	fee_supplier MONEY NULL
	)
GO

