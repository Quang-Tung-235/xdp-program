; ModuleID = 'xdp_prog_kern.c'
source_filename = "xdp_prog_kern.c"
target datalayout = "e-m:e-p:64:64-i64:64-i128:128-n32:64-S128"
target triple = "bpf"

%struct.anon = type { ptr, ptr, ptr, ptr }
%struct.anon.0 = type { ptr, ptr, ptr, ptr }
%struct.anon.1 = type { ptr, ptr, ptr, ptr }
%struct.data_point = type { i64, i64, i64, i32, i32, i32, i32, [6 x i64], i32 }
%struct.flow_key = type <{ i32, i16, i32, i16, i8 }>
%struct.xdp_md = type { i32, i32, i32, i32, i32, i32 }
%struct.ethhdr = type { [6 x i8], [6 x i8], i16 }
%struct.icmphdr = type { i8, i8, i16, %union.anon.4 }
%union.anon.4 = type { i32 }
%struct.tcphdr = type { i16, i16, i32, i32, i16, i16, i16, i16 }
%struct.udphdr = type { i16, i16, i16, i16 }
%struct.dt_tree = type { [5000 x %struct.dt_node], i32, [6 x i64], [6 x i64] }
%struct.dt_node = type { i32, i32, i64, i32, i32, i32 }
%struct.accounting = type { i64, i64, i32, i32 }

@accounting_map = dso_local global %struct.anon zeroinitializer, section ".maps", align 8, !dbg !0
@_license = dso_local global [4 x i8] c"GPL\00", section "license", align 1, !dbg !149
@dt_map = dso_local global %struct.anon.0 zeroinitializer, section ".maps", align 8, !dbg !153
@xdp_flow_tracking = dso_local global %struct.anon.1 zeroinitializer, section ".maps", align 8, !dbg !196
@llvm.compiler.used = appending global [5 x ptr] [ptr @_license, ptr @accounting_map, ptr @dt_map, ptr @xdp_anomaly_detector, ptr @xdp_flow_tracking], section "llvm.metadata"

; Function Attrs: nounwind
define dso_local noundef i32 @xdp_anomaly_detector(ptr nocapture noundef readonly %0) #0 section "xdp" !dbg !267 {
  %2 = alloca %struct.data_point, align 8, !DIAssignID !289
  %3 = alloca i32, align 4, !DIAssignID !290
  %4 = alloca %struct.flow_key, align 4, !DIAssignID !291
  call void @llvm.dbg.assign(metadata i1 undef, metadata !281, metadata !DIExpression(), metadata !291, metadata ptr %4, metadata !DIExpression()), !dbg !292
  %5 = alloca i32, align 4, !DIAssignID !293
  call void @llvm.dbg.assign(metadata i1 undef, metadata !283, metadata !DIExpression(), metadata !293, metadata ptr %5, metadata !DIExpression()), !dbg !292
  tail call void @llvm.dbg.value(metadata ptr %0, metadata !280, metadata !DIExpression()), !dbg !292
  call void @llvm.lifetime.start.p0(i64 13, ptr nonnull %4) #6, !dbg !294
  %6 = getelementptr inbounds i8, ptr %4, i64 4, !dbg !295
  store i64 0, ptr %6, align 4, !dbg !295, !DIAssignID !296
  call void @llvm.dbg.assign(metadata i64 0, metadata !281, metadata !DIExpression(), metadata !296, metadata ptr %4, metadata !DIExpression()), !dbg !292
  call void @llvm.dbg.assign(metadata i8 0, metadata !281, metadata !DIExpression(DW_OP_LLVM_fragment, 0, 32), metadata !297, metadata ptr undef, metadata !DIExpression()), !dbg !292
  call void @llvm.dbg.assign(metadata i8 0, metadata !281, metadata !DIExpression(DW_OP_LLVM_fragment, 96, 8), metadata !298, metadata ptr undef, metadata !DIExpression()), !dbg !292
  tail call void @llvm.dbg.value(metadata i64 0, metadata !282, metadata !DIExpression()), !dbg !292
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %5) #6, !dbg !299
  store i32 0, ptr %5, align 4, !dbg !300, !tbaa !301, !DIAssignID !305
  call void @llvm.dbg.assign(metadata i32 0, metadata !283, metadata !DIExpression(), metadata !305, metadata ptr %5, metadata !DIExpression()), !dbg !292
  call void @llvm.dbg.value(metadata ptr %0, metadata !306, metadata !DIExpression()), !dbg !337
  call void @llvm.dbg.value(metadata ptr %4, metadata !312, metadata !DIExpression()), !dbg !337
  call void @llvm.dbg.value(metadata ptr undef, metadata !313, metadata !DIExpression()), !dbg !337
  %7 = getelementptr inbounds %struct.xdp_md, ptr %0, i64 0, i32 1, !dbg !339
  %8 = load i32, ptr %7, align 4, !dbg !339, !tbaa !340
  %9 = zext i32 %8 to i64, !dbg !342
  %10 = inttoptr i64 %9 to ptr, !dbg !343
  call void @llvm.dbg.value(metadata ptr %10, metadata !314, metadata !DIExpression()), !dbg !337
  %11 = load i32, ptr %0, align 4, !dbg !344, !tbaa !345
  %12 = zext i32 %11 to i64, !dbg !346
  %13 = inttoptr i64 %12 to ptr, !dbg !347
  call void @llvm.dbg.value(metadata ptr %13, metadata !315, metadata !DIExpression()), !dbg !337
  call void @llvm.dbg.value(metadata ptr %13, metadata !316, metadata !DIExpression()), !dbg !337
  %14 = getelementptr inbounds %struct.ethhdr, ptr %13, i64 1, !dbg !348
  %15 = icmp ugt ptr %14, %10, !dbg !350
  br i1 %15, label %86, label %16, !dbg !351

16:                                               ; preds = %1
  %17 = getelementptr inbounds %struct.ethhdr, ptr %13, i64 0, i32 2, !dbg !352
  %18 = load i16, ptr %17, align 1, !dbg !352, !tbaa !354
  switch i16 %18, label %86 [
    i16 -13176, label %258
    i16 8, label %19
  ], !dbg !357

19:                                               ; preds = %16
  call void @llvm.dbg.value(metadata ptr %14, metadata !325, metadata !DIExpression()), !dbg !337
  %20 = getelementptr inbounds %struct.ethhdr, ptr %13, i64 2, i32 1, !dbg !358
  %21 = icmp ugt ptr %20, %10, !dbg !360
  br i1 %21, label %86, label %22, !dbg !361

22:                                               ; preds = %19
  %23 = getelementptr inbounds %struct.ethhdr, ptr %13, i64 1, i32 2, !dbg !362
  %24 = load i32, ptr %23, align 4, !dbg !362, !tbaa !363
  store i32 %24, ptr %4, align 4, !dbg !364, !tbaa !365, !DIAssignID !367
  call void @llvm.dbg.assign(metadata i32 %24, metadata !281, metadata !DIExpression(DW_OP_LLVM_fragment, 0, 32), metadata !367, metadata ptr %4, metadata !DIExpression()), !dbg !292
  %25 = getelementptr inbounds %struct.ethhdr, ptr %13, i64 2, i32 0, i64 2, !dbg !368
  %26 = load i32, ptr %25, align 4, !dbg !368, !tbaa !363
  %27 = getelementptr inbounds %struct.flow_key, ptr %4, i64 0, i32 2, !dbg !369
  store i32 %26, ptr %27, align 2, !dbg !370, !tbaa !371, !DIAssignID !372
  call void @llvm.dbg.assign(metadata i32 %26, metadata !281, metadata !DIExpression(DW_OP_LLVM_fragment, 48, 32), metadata !372, metadata ptr %27, metadata !DIExpression()), !dbg !292
  %28 = getelementptr inbounds %struct.ethhdr, ptr %13, i64 1, i32 1, i64 3, !dbg !373
  %29 = load i8, ptr %28, align 1, !dbg !373, !tbaa !374
  %30 = getelementptr inbounds %struct.flow_key, ptr %4, i64 0, i32 4, !dbg !376
  store i8 %29, ptr %30, align 4, !dbg !377, !tbaa !378, !DIAssignID !379
  call void @llvm.dbg.assign(metadata i8 %29, metadata !281, metadata !DIExpression(DW_OP_LLVM_fragment, 96, 8), metadata !379, metadata ptr %30, metadata !DIExpression()), !dbg !292
  switch i8 %29, label %78 [
    i8 1, label %31
    i8 6, label %53
    i8 17, label %63
  ], !dbg !380

31:                                               ; preds = %22
  %32 = load i8, ptr %14, align 4, !dbg !381
  %33 = shl i8 %32, 2, !dbg !382
  %34 = and i8 %33, 60, !dbg !382
  %35 = zext nneg i8 %34 to i64
  %36 = getelementptr inbounds i8, ptr %14, i64 %35, !dbg !383
  call void @llvm.dbg.value(metadata ptr %36, metadata !326, metadata !DIExpression()), !dbg !384
  %37 = getelementptr inbounds %struct.icmphdr, ptr %36, i64 1, !dbg !385
  %38 = icmp ugt ptr %37, %10, !dbg !387
  br i1 %38, label %258, label %39, !dbg !388

39:                                               ; preds = %31
  call void @llvm.dbg.value(metadata i32 poison, metadata !329, metadata !DIExpression()), !dbg !384
  call void @llvm.dbg.value(metadata i32 poison, metadata !330, metadata !DIExpression()), !dbg !384
  %40 = icmp eq i32 %24, 53651648, !dbg !389
  %41 = icmp eq i32 %26, 70428864
  %42 = select i1 %40, i1 %41, i1 false, !dbg !391
  br i1 %42, label %43, label %46, !dbg !391

43:                                               ; preds = %39
  %44 = load i8, ptr %36, align 4, !dbg !392, !tbaa !393
  %45 = icmp eq i8 %44, 8, !dbg !395
  br i1 %45, label %87, label %78, !dbg !396

46:                                               ; preds = %39
  call void @llvm.dbg.value(metadata i32 poison, metadata !330, metadata !DIExpression()), !dbg !384
  call void @llvm.dbg.value(metadata i32 poison, metadata !329, metadata !DIExpression()), !dbg !384
  %47 = icmp eq i32 %24, 70428864, !dbg !397
  %48 = icmp eq i32 %26, 53651648
  %49 = select i1 %47, i1 %48, i1 false, !dbg !398
  br i1 %49, label %50, label %78, !dbg !398

50:                                               ; preds = %46
  %51 = load i8, ptr %36, align 4, !dbg !399, !tbaa !393
  %52 = icmp eq i8 %51, 0, !dbg !400
  br i1 %52, label %87, label %78, !dbg !401

53:                                               ; preds = %22
  %54 = load i8, ptr %14, align 4, !dbg !402
  %55 = shl i8 %54, 2, !dbg !403
  %56 = and i8 %55, 60, !dbg !403
  %57 = zext nneg i8 %56 to i64
  %58 = getelementptr inbounds i8, ptr %14, i64 %57, !dbg !404
  call void @llvm.dbg.value(metadata ptr %58, metadata !331, metadata !DIExpression()), !dbg !405
  %59 = getelementptr inbounds %struct.tcphdr, ptr %58, i64 1, !dbg !406
  %60 = icmp ugt ptr %59, %10, !dbg !408
  br i1 %60, label %86, label %61, !dbg !409

61:                                               ; preds = %53
  call void @llvm.dbg.assign(metadata i16 poison, metadata !281, metadata !DIExpression(DW_OP_LLVM_fragment, 32, 16), metadata !410, metadata ptr %4, metadata !DIExpression(DW_OP_plus_uconst, 4)), !dbg !292
  %62 = getelementptr inbounds %struct.tcphdr, ptr %58, i64 0, i32 1, !dbg !411
  call void @llvm.dbg.assign(metadata i16 %77, metadata !281, metadata !DIExpression(DW_OP_LLVM_fragment, 80, 16), metadata !412, metadata ptr %4, metadata !DIExpression(DW_OP_plus_uconst, 10)), !dbg !292
  br label %73

63:                                               ; preds = %22
  %64 = load i8, ptr %14, align 4, !dbg !413
  %65 = shl i8 %64, 2, !dbg !414
  %66 = and i8 %65, 60, !dbg !414
  %67 = zext nneg i8 %66 to i64
  %68 = getelementptr inbounds i8, ptr %14, i64 %67, !dbg !415
  call void @llvm.dbg.value(metadata ptr %68, metadata !334, metadata !DIExpression()), !dbg !416
  %69 = getelementptr inbounds %struct.udphdr, ptr %68, i64 1, !dbg !417
  %70 = icmp ugt ptr %69, %10, !dbg !419
  br i1 %70, label %86, label %71, !dbg !420

71:                                               ; preds = %63
  call void @llvm.dbg.assign(metadata i16 poison, metadata !281, metadata !DIExpression(DW_OP_LLVM_fragment, 32, 16), metadata !421, metadata ptr %4, metadata !DIExpression(DW_OP_plus_uconst, 4)), !dbg !292
  %72 = getelementptr inbounds %struct.udphdr, ptr %68, i64 0, i32 1, !dbg !422
  call void @llvm.dbg.assign(metadata i16 %77, metadata !281, metadata !DIExpression(DW_OP_LLVM_fragment, 80, 16), metadata !423, metadata ptr %4, metadata !DIExpression(DW_OP_plus_uconst, 10)), !dbg !292
  br label %73

73:                                               ; preds = %71, %61
  %74 = phi ptr [ %62, %61 ], [ %72, %71 ]
  %75 = phi ptr [ %58, %61 ], [ %68, %71 ]
  %76 = load i16, ptr %75, align 2, !dbg !424, !tbaa !425
  %77 = load i16, ptr %74, align 2, !dbg !424, !tbaa !425
  br label %78, !dbg !426

78:                                               ; preds = %73, %50, %46, %43, %22
  %79 = phi i16 [ 0, %22 ], [ 0, %43 ], [ 0, %46 ], [ 0, %50 ], [ %77, %73 ], !dbg !427
  %80 = phi i16 [ 0, %22 ], [ 0, %43 ], [ 0, %46 ], [ 0, %50 ], [ %76, %73 ], !dbg !426
  %81 = getelementptr inbounds %struct.flow_key, ptr %4, i64 0, i32 1, !dbg !426
  %82 = tail call i16 @llvm.bswap.i16(i16 %80), !dbg !426
  store i16 %82, ptr %81, align 4, !dbg !428, !tbaa !429, !DIAssignID !430
  call void @llvm.dbg.assign(metadata i16 %82, metadata !281, metadata !DIExpression(DW_OP_LLVM_fragment, 32, 16), metadata !430, metadata ptr %81, metadata !DIExpression()), !dbg !292
  %83 = getelementptr inbounds %struct.flow_key, ptr %4, i64 0, i32 3, !dbg !427
  %84 = tail call i16 @llvm.bswap.i16(i16 %79), !dbg !427
  store i16 %84, ptr %83, align 2, !dbg !431, !tbaa !432, !DIAssignID !433
  call void @llvm.dbg.assign(metadata i16 %84, metadata !281, metadata !DIExpression(DW_OP_LLVM_fragment, 80, 16), metadata !433, metadata ptr %83, metadata !DIExpression()), !dbg !292
  %85 = sub i32 %8, %11, !dbg !434
  tail call void @llvm.dbg.value(metadata !DIArgList(i64 %9, i64 %12), metadata !282, metadata !DIExpression(DW_OP_LLVM_arg, 0, DW_OP_LLVM_arg, 1, DW_OP_minus, DW_OP_stack_value)), !dbg !292
  tail call void @llvm.dbg.value(metadata i32 0, metadata !284, metadata !DIExpression()), !dbg !292
  br label %87, !dbg !435

86:                                               ; preds = %19, %1, %16, %53, %63
  tail call void @llvm.dbg.value(metadata i64 poison, metadata !282, metadata !DIExpression()), !dbg !292
  tail call void @llvm.dbg.value(metadata i32 -1, metadata !284, metadata !DIExpression()), !dbg !292
  br label %258, !dbg !435

87:                                               ; preds = %43, %50, %78
  %88 = phi i32 [ %85, %78 ], [ 0, %50 ], [ 0, %43 ]
  call void @llvm.dbg.assign(metadata i1 undef, metadata !436, metadata !DIExpression(), metadata !289, metadata ptr %2, metadata !DIExpression()), !dbg !462
  call void @llvm.dbg.assign(metadata i1 undef, metadata !457, metadata !DIExpression(), metadata !290, metadata ptr %3, metadata !DIExpression()), !dbg !464
  call void @llvm.dbg.value(metadata ptr %4, metadata !443, metadata !DIExpression()), !dbg !464
  call void @llvm.dbg.value(metadata ptr %0, metadata !444, metadata !DIExpression()), !dbg !464
  %89 = tail call i64 inttoptr (i64 5 to ptr)() #6, !dbg !465
  call void @llvm.dbg.value(metadata i64 %89, metadata !445, metadata !DIExpression()), !dbg !464
  %90 = freeze i64 %89, !dbg !466
  %91 = load i32, ptr %7, align 4, !dbg !467, !tbaa !340
  %92 = zext i32 %91 to i64, !dbg !468
  %93 = load i32, ptr %0, align 4, !dbg !469, !tbaa !345
  %94 = zext i32 %93 to i64, !dbg !470
  %95 = sub nsw i64 %92, %94, !dbg !471
  call void @llvm.dbg.value(metadata i64 %95, metadata !446, metadata !DIExpression()), !dbg !464
  call void @llvm.dbg.value(metadata i32 2, metadata !447, metadata !DIExpression()), !dbg !464
  call void @llvm.dbg.value(metadata i32 0, metadata !448, metadata !DIExpression()), !dbg !464
  %96 = call ptr inttoptr (i64 1 to ptr)(ptr noundef nonnull @xdp_flow_tracking, ptr noundef nonnull %4) #6, !dbg !472
  call void @llvm.dbg.value(metadata ptr %96, metadata !449, metadata !DIExpression()), !dbg !464
  %97 = icmp eq ptr %96, null, !dbg !473
  br i1 %97, label %98, label %119, !dbg !474

98:                                               ; preds = %87
  call void @llvm.lifetime.start.p0(i64 96, ptr nonnull %2) #6, !dbg !475
  %99 = getelementptr inbounds i8, ptr %2, i64 88, !dbg !476
  store i64 0, ptr %99, align 8, !dbg !476, !DIAssignID !477
  call void @llvm.dbg.assign(metadata i64 0, metadata !436, metadata !DIExpression(), metadata !477, metadata ptr %2, metadata !DIExpression()), !dbg !462
  call void @llvm.dbg.assign(metadata i8 0, metadata !436, metadata !DIExpression(DW_OP_LLVM_fragment, 0, 704), metadata !478, metadata ptr undef, metadata !DIExpression()), !dbg !462
  store i64 %90, ptr %2, align 8, !dbg !479, !tbaa !480, !DIAssignID !483
  call void @llvm.dbg.assign(metadata i64 %89, metadata !436, metadata !DIExpression(DW_OP_LLVM_fragment, 0, 64), metadata !483, metadata ptr %2, metadata !DIExpression()), !dbg !462
  %100 = getelementptr inbounds %struct.data_point, ptr %2, i64 0, i32 1, !dbg !484
  store i64 %90, ptr %100, align 8, !dbg !485, !tbaa !486, !DIAssignID !487
  call void @llvm.dbg.assign(metadata i64 %89, metadata !436, metadata !DIExpression(DW_OP_LLVM_fragment, 64, 64), metadata !487, metadata ptr %100, metadata !DIExpression()), !dbg !462
  %101 = getelementptr inbounds %struct.data_point, ptr %2, i64 0, i32 2, !dbg !488
  store i64 -1, ptr %101, align 8, !dbg !489, !tbaa !490, !DIAssignID !491
  call void @llvm.dbg.assign(metadata i64 -1, metadata !436, metadata !DIExpression(DW_OP_LLVM_fragment, 128, 64), metadata !491, metadata ptr %101, metadata !DIExpression()), !dbg !462
  %102 = getelementptr inbounds %struct.data_point, ptr %2, i64 0, i32 3, !dbg !492
  store i32 1, ptr %102, align 8, !dbg !493, !tbaa !494, !DIAssignID !495
  call void @llvm.dbg.assign(metadata i32 1, metadata !436, metadata !DIExpression(DW_OP_LLVM_fragment, 192, 32), metadata !495, metadata ptr %102, metadata !DIExpression()), !dbg !462
  %103 = trunc i64 %95 to i32, !dbg !496
  %104 = getelementptr inbounds %struct.data_point, ptr %2, i64 0, i32 4, !dbg !497
  store i32 %103, ptr %104, align 4, !dbg !498, !tbaa !499, !DIAssignID !500
  call void @llvm.dbg.assign(metadata i32 %103, metadata !436, metadata !DIExpression(DW_OP_LLVM_fragment, 224, 32), metadata !500, metadata ptr %104, metadata !DIExpression()), !dbg !462
  %105 = getelementptr inbounds %struct.data_point, ptr %2, i64 0, i32 5, !dbg !501
  store i32 %103, ptr %105, align 8, !dbg !502, !tbaa !503, !DIAssignID !504
  call void @llvm.dbg.assign(metadata i32 %103, metadata !436, metadata !DIExpression(DW_OP_LLVM_fragment, 256, 32), metadata !504, metadata ptr %105, metadata !DIExpression()), !dbg !462
  %106 = getelementptr inbounds %struct.data_point, ptr %2, i64 0, i32 6, !dbg !505
  store i32 %103, ptr %106, align 4, !dbg !506, !tbaa !507, !DIAssignID !508
  call void @llvm.dbg.assign(metadata i32 %103, metadata !436, metadata !DIExpression(DW_OP_LLVM_fragment, 288, 32), metadata !508, metadata ptr %106, metadata !DIExpression()), !dbg !462
  call void @llvm.dbg.assign(metadata i32 0, metadata !436, metadata !DIExpression(DW_OP_LLVM_fragment, 704, 32), metadata !509, metadata ptr %2, metadata !DIExpression(DW_OP_plus_uconst, 88)), !dbg !462
  call void @llvm.dbg.value(metadata i32 0, metadata !450, metadata !DIExpression()), !dbg !510
  %107 = getelementptr inbounds i8, ptr %2, i64 40, !dbg !511
  call void @llvm.dbg.value(metadata i64 poison, metadata !450, metadata !DIExpression()), !dbg !510
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(52) %107, i8 0, i64 52, i1 false), !dbg !512, !DIAssignID !509
  %108 = call i64 inttoptr (i64 2 to ptr)(ptr noundef nonnull @xdp_flow_tracking, ptr noundef nonnull %4, ptr noundef nonnull %2, i64 noundef 0) #6, !dbg !515
  %109 = icmp eq i64 %108, 0, !dbg !517
  br i1 %109, label %111, label %110, !dbg !518

110:                                              ; preds = %98
  call void @llvm.dbg.value(metadata i32 poison, metadata !448, metadata !DIExpression()), !dbg !464
  call void @llvm.dbg.value(metadata ptr poison, metadata !449, metadata !DIExpression()), !dbg !464
  call void @llvm.lifetime.end.p0(i64 96, ptr nonnull %2) #6, !dbg !519
  br label %241

111:                                              ; preds = %98
  %112 = call ptr inttoptr (i64 1 to ptr)(ptr noundef nonnull @xdp_flow_tracking, ptr noundef nonnull %4) #6, !dbg !520
  call void @llvm.dbg.value(metadata ptr %112, metadata !449, metadata !DIExpression()), !dbg !464
  %113 = icmp eq ptr %112, null, !dbg !521
  call void @llvm.dbg.value(metadata i32 poison, metadata !448, metadata !DIExpression()), !dbg !464
  call void @llvm.lifetime.end.p0(i64 96, ptr nonnull %2) #6, !dbg !519
  br i1 %113, label %241, label %114

114:                                              ; preds = %111
  %115 = getelementptr inbounds %struct.data_point, ptr %112, i64 0, i32 4
  %116 = load i32, ptr %115, align 4, !dbg !523, !tbaa !499
  %117 = getelementptr inbounds %struct.data_point, ptr %112, i64 0, i32 5
  %118 = load i32, ptr %117, align 8, !dbg !524, !tbaa !503
  br label %150

119:                                              ; preds = %87
  %120 = getelementptr inbounds %struct.data_point, ptr %96, i64 0, i32 1, !dbg !525
  %121 = load i64, ptr %120, align 8, !dbg !525, !tbaa !486
  %122 = add i64 %121, -1, !dbg !466
  %123 = icmp uge i64 %122, %90, !dbg !466
  %124 = sub i64 %90, %121, !dbg !466
  call void @llvm.dbg.value(metadata i64 poison, metadata !452, metadata !DIExpression()), !dbg !526
  %125 = getelementptr inbounds %struct.data_point, ptr %96, i64 0, i32 3, !dbg !527
  %126 = atomicrmw add ptr %125, i32 1 seq_cst, align 8, !dbg !528
  %127 = getelementptr inbounds %struct.data_point, ptr %96, i64 0, i32 6, !dbg !529
  %128 = trunc i64 %95 to i32, !dbg !530
  %129 = atomicrmw add ptr %127, i32 %128 seq_cst, align 4, !dbg !531
  %130 = icmp eq i64 %90, %121, !dbg !532
  %131 = or i1 %130, %123, !dbg !532
  br i1 %131, label %137, label %132, !dbg !534

132:                                              ; preds = %119
  %133 = getelementptr inbounds %struct.data_point, ptr %96, i64 0, i32 2, !dbg !535
  %134 = load i64, ptr %133, align 8, !dbg !535, !tbaa !490
  %135 = icmp ult i64 %124, %134, !dbg !536
  br i1 %135, label %136, label %137, !dbg !537

136:                                              ; preds = %132
  store i64 %124, ptr %133, align 8, !dbg !538, !tbaa !490
  br label %137, !dbg !539

137:                                              ; preds = %136, %132, %119
  %138 = getelementptr inbounds %struct.data_point, ptr %96, i64 0, i32 4, !dbg !540
  %139 = load i32, ptr %138, align 4, !dbg !540, !tbaa !499
  %140 = zext i32 %139 to i64, !dbg !542
  %141 = icmp ugt i64 %95, %140, !dbg !543
  br i1 %141, label %142, label %143, !dbg !544

142:                                              ; preds = %137
  store i32 %128, ptr %138, align 4, !dbg !545, !tbaa !499
  br label %143, !dbg !546

143:                                              ; preds = %142, %137
  %144 = phi i32 [ %128, %142 ], [ %139, %137 ]
  %145 = getelementptr inbounds %struct.data_point, ptr %96, i64 0, i32 5, !dbg !547
  %146 = load i32, ptr %145, align 8, !dbg !547, !tbaa !503
  %147 = zext i32 %146 to i64, !dbg !549
  %148 = icmp ult i64 %95, %147, !dbg !550
  br i1 %148, label %149, label %150, !dbg !551

149:                                              ; preds = %143
  store i32 %128, ptr %145, align 8, !dbg !552, !tbaa !503
  br label %150, !dbg !553

150:                                              ; preds = %114, %149, %143
  %151 = phi i32 [ %128, %149 ], [ %146, %143 ], [ %118, %114 ], !dbg !524
  %152 = phi i32 [ %144, %149 ], [ %144, %143 ], [ %116, %114 ], !dbg !523
  %153 = phi ptr [ %96, %149 ], [ %96, %143 ], [ %112, %114 ]
  %154 = getelementptr inbounds %struct.data_point, ptr %153, i64 0, i32 1, !dbg !554
  store i64 %90, ptr %154, align 8, !dbg !555, !tbaa !486
  %155 = load i64, ptr %153, align 8, !dbg !556, !tbaa !480
  %156 = sub i64 %90, %155, !dbg !557
  %157 = udiv i64 %156, 1000, !dbg !558
  call void @llvm.dbg.value(metadata i64 %157, metadata !455, metadata !DIExpression()), !dbg !464
  tail call void @llvm.dbg.value(metadata i64 %157, metadata !559, metadata !DIExpression()), !dbg !564
  %158 = shl i64 %157, 16, !dbg !566
  %159 = getelementptr inbounds %struct.data_point, ptr %153, i64 0, i32 7, !dbg !567
  store i64 %158, ptr %159, align 8, !dbg !568, !tbaa !569
  %160 = getelementptr inbounds %struct.data_point, ptr %153, i64 0, i32 3, !dbg !570
  %161 = load i32, ptr %160, align 8, !dbg !570, !tbaa !494
  %162 = zext i32 %161 to i64, !dbg !571
  tail call void @llvm.dbg.value(metadata i64 %162, metadata !559, metadata !DIExpression()), !dbg !572
  %163 = shl nuw nsw i64 %162, 16, !dbg !574
  %164 = getelementptr inbounds %struct.data_point, ptr %153, i64 0, i32 7, i64 1, !dbg !575
  store i64 %163, ptr %164, align 8, !dbg !576, !tbaa !569
  %165 = getelementptr inbounds %struct.data_point, ptr %153, i64 0, i32 6, !dbg !577
  %166 = load i32, ptr %165, align 4, !dbg !577, !tbaa !507
  %167 = zext i32 %166 to i64, !dbg !578
  tail call void @llvm.dbg.value(metadata i64 %167, metadata !559, metadata !DIExpression()), !dbg !579
  %168 = shl nuw nsw i64 %167, 16, !dbg !581
  %169 = getelementptr inbounds %struct.data_point, ptr %153, i64 0, i32 7, i64 2, !dbg !582
  store i64 %168, ptr %169, align 8, !dbg !583, !tbaa !569
  %170 = zext i32 %152 to i64, !dbg !584
  tail call void @llvm.dbg.value(metadata i64 %170, metadata !559, metadata !DIExpression()), !dbg !585
  %171 = shl nuw nsw i64 %170, 16, !dbg !587
  %172 = getelementptr inbounds %struct.data_point, ptr %153, i64 0, i32 7, i64 3, !dbg !588
  store i64 %171, ptr %172, align 8, !dbg !589, !tbaa !569
  %173 = zext i32 %151 to i64, !dbg !590
  tail call void @llvm.dbg.value(metadata i64 %173, metadata !559, metadata !DIExpression()), !dbg !591
  %174 = shl nuw nsw i64 %173, 16, !dbg !593
  %175 = getelementptr inbounds %struct.data_point, ptr %153, i64 0, i32 7, i64 4, !dbg !594
  store i64 %174, ptr %175, align 8, !dbg !595, !tbaa !569
  %176 = getelementptr inbounds %struct.data_point, ptr %153, i64 0, i32 2, !dbg !596
  %177 = load i64, ptr %176, align 8, !dbg !596, !tbaa !490
  %178 = icmp eq i64 %177, -1, !dbg !597
  %179 = udiv i64 %177, 1000, !dbg !598
  %180 = shl i64 %179, 16, !dbg !599
  call void @llvm.dbg.value(metadata i64 poison, metadata !456, metadata !DIExpression()), !dbg !464
  tail call void @llvm.dbg.value(metadata i64 poison, metadata !559, metadata !DIExpression()), !dbg !601
  %181 = select i1 %178, i64 0, i64 %180, !dbg !599
  %182 = getelementptr inbounds %struct.data_point, ptr %153, i64 0, i32 7, i64 5, !dbg !602
  store i64 %181, ptr %182, align 8, !dbg !603, !tbaa !569
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %3) #6, !dbg !604
  store i32 0, ptr %3, align 4, !dbg !605, !tbaa !301, !DIAssignID !606
  call void @llvm.dbg.assign(metadata i32 0, metadata !457, metadata !DIExpression(), metadata !606, metadata ptr %3, metadata !DIExpression()), !dbg !464
  %183 = call ptr inttoptr (i64 1 to ptr)(ptr noundef nonnull @dt_map, ptr noundef nonnull %3) #6, !dbg !607
  call void @llvm.dbg.value(metadata ptr %183, metadata !458, metadata !DIExpression()), !dbg !464
  %184 = icmp eq ptr %183, null, !dbg !608
  br i1 %184, label %237, label %185, !dbg !609

185:                                              ; preds = %150
  call void @llvm.dbg.value(metadata ptr %153, metadata !610, metadata !DIExpression()), !dbg !627
  call void @llvm.dbg.value(metadata ptr %183, metadata !617, metadata !DIExpression()), !dbg !627
  %186 = getelementptr inbounds %struct.dt_tree, ptr %183, i64 0, i32 1, !dbg !629
  %187 = load i32, ptr %186, align 8, !dbg !629, !tbaa !631
  %188 = icmp eq i32 %187, 0, !dbg !633
  br i1 %188, label %237, label %189, !dbg !634

189:                                              ; preds = %185, %233
  %190 = phi i32 [ %234, %233 ], [ 0, %185 ]
  %191 = phi i32 [ %235, %233 ], [ 0, %185 ]
  call void @llvm.dbg.value(metadata i32 %190, metadata !618, metadata !DIExpression()), !dbg !627
  call void @llvm.dbg.value(metadata i32 %191, metadata !619, metadata !DIExpression()), !dbg !635
  %192 = icmp uge i32 %190, %187, !dbg !636
  %193 = icmp ugt i32 %190, 4999
  %194 = call i1 @llvm.bpf.passthrough.i1.i1(i32 0, i1 %192)
  %195 = select i1 %194, i1 true, i1 %193, !dbg !638
  br i1 %195, label %237, label %196, !dbg !638

196:                                              ; preds = %189
  %197 = zext nneg i32 %190 to i64, !dbg !639
  %198 = getelementptr inbounds [5000 x %struct.dt_node], ptr %183, i64 0, i64 %197, !dbg !639
  call void @llvm.dbg.value(metadata ptr %198, metadata !621, metadata !DIExpression()), !dbg !640
  %199 = getelementptr inbounds [5000 x %struct.dt_node], ptr %183, i64 0, i64 %197, i32 4, !dbg !641
  %200 = load i32, ptr %199, align 4, !dbg !641, !tbaa !643
  %201 = icmp eq i32 %200, 0, !dbg !645
  br i1 %201, label %205, label %202, !dbg !646

202:                                              ; preds = %196
  %203 = getelementptr inbounds [5000 x %struct.dt_node], ptr %183, i64 0, i64 %197, i32 5, !dbg !647
  %204 = load i32, ptr %203, align 8, !dbg !647, !tbaa !649
  br label %237, !dbg !650

205:                                              ; preds = %196
  %206 = getelementptr inbounds [5000 x %struct.dt_node], ptr %183, i64 0, i64 %197, i32 3, !dbg !651
  %207 = load i32, ptr %206, align 8, !dbg !651, !tbaa !653
  %208 = icmp slt i32 %207, 0, !dbg !654
  %209 = call i1 @llvm.bpf.passthrough.i1.i1(i32 2, i1 %208)
  %210 = icmp sgt i32 %207, 5
  %211 = select i1 %209, i1 true, i1 %210, !dbg !655
  br i1 %211, label %237, label %212, !dbg !655

212:                                              ; preds = %205
  %213 = call i32 @llvm.bpf.passthrough.i32.i32(i32 1, i32 %207)
  %214 = sext i32 %213 to i64, !dbg !656
  %215 = getelementptr inbounds %struct.data_point, ptr %153, i64 0, i32 7, i64 %214, !dbg !656
  %216 = load i64, ptr %215, align 8, !dbg !656, !tbaa !569
  call void @llvm.dbg.value(metadata i64 %216, metadata !626, metadata !DIExpression()), !dbg !640
  %217 = getelementptr inbounds [5000 x %struct.dt_node], ptr %183, i64 0, i64 %197, i32 2, !dbg !657
  %218 = load i64, ptr %217, align 8, !dbg !657, !tbaa !659
  %219 = icmp ugt i64 %216, %218, !dbg !660
  br i1 %219, label %226, label %220, !dbg !661

220:                                              ; preds = %212
  %221 = load i32, ptr %198, align 8, !dbg !662, !tbaa !665
  %222 = icmp slt i32 %221, 0, !dbg !666
  %223 = call i1 @llvm.bpf.passthrough.i1.i1(i32 3, i1 %222)
  %224 = icmp sgt i32 %221, 4999
  %225 = select i1 %223, i1 true, i1 %224, !dbg !667
  br i1 %225, label %237, label %233, !dbg !667

226:                                              ; preds = %212
  %227 = getelementptr inbounds [5000 x %struct.dt_node], ptr %183, i64 0, i64 %197, i32 1, !dbg !668
  %228 = load i32, ptr %227, align 4, !dbg !668, !tbaa !671
  %229 = icmp slt i32 %228, 0, !dbg !672
  %230 = call i1 @llvm.bpf.passthrough.i1.i1(i32 4, i1 %229)
  %231 = icmp sgt i32 %228, 4999
  %232 = select i1 %230, i1 true, i1 %231, !dbg !673
  br i1 %232, label %237, label %233, !dbg !673

233:                                              ; preds = %226, %220
  %234 = phi i32 [ %221, %220 ], [ %228, %226 ], !dbg !674
  call void @llvm.dbg.value(metadata i32 %234, metadata !618, metadata !DIExpression()), !dbg !627
  %235 = add nuw nsw i32 %191, 1, !dbg !675
  call void @llvm.dbg.value(metadata i32 %235, metadata !619, metadata !DIExpression()), !dbg !635
  %236 = icmp eq i32 %235, 100, !dbg !676
  br i1 %236, label %237, label %189, !dbg !677, !llvm.loop !678

237:                                              ; preds = %226, %220, %205, %189, %233, %150, %185, %202
  %238 = phi i32 [ 0, %185 ], [ %204, %202 ], [ 0, %150 ], [ 0, %233 ], [ 0, %189 ], [ 0, %205 ], [ 0, %220 ], [ 0, %226 ]
  %239 = getelementptr inbounds %struct.data_point, ptr %153, i64 0, i32 8, !dbg !681
  store i32 %238, ptr %239, align 8, !dbg !681, !tbaa !682
  %240 = call i64 inttoptr (i64 2 to ptr)(ptr noundef nonnull @xdp_flow_tracking, ptr noundef nonnull %4, ptr noundef nonnull %153, i64 noundef 0) #6, !dbg !683
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %3) #6, !dbg !685
  br label %241

241:                                              ; preds = %110, %111, %237
  tail call void @llvm.dbg.value(metadata i32 2, metadata !284, metadata !DIExpression()), !dbg !292
  %242 = call ptr inttoptr (i64 1 to ptr)(ptr noundef nonnull @accounting_map, ptr noundef nonnull %5) #6, !dbg !686
  tail call void @llvm.dbg.value(metadata ptr %242, metadata !285, metadata !DIExpression()), !dbg !292
  %243 = icmp eq ptr %242, null, !dbg !687
  br i1 %243, label %258, label %244, !dbg !688

244:                                              ; preds = %241
  %245 = call i64 inttoptr (i64 5 to ptr)() #6, !dbg !689
  tail call void @llvm.dbg.value(metadata i64 %245, metadata !286, metadata !DIExpression()), !dbg !690
  %246 = load i64, ptr %242, align 8, !dbg !691, !tbaa !692
  %247 = sub i64 %245, %246, !dbg !694
  %248 = getelementptr inbounds %struct.accounting, ptr %242, i64 0, i32 1, !dbg !695
  %249 = load i64, ptr %248, align 8, !dbg !696, !tbaa !697
  %250 = add i64 %247, %249, !dbg !696
  store i64 %250, ptr %248, align 8, !dbg !696, !tbaa !697
  %251 = getelementptr inbounds %struct.accounting, ptr %242, i64 0, i32 3, !dbg !698
  %252 = load i32, ptr %251, align 4, !dbg !699, !tbaa !700
  %253 = add i32 %252, %88, !dbg !699
  store i32 %253, ptr %251, align 4, !dbg !699, !tbaa !700
  %254 = getelementptr inbounds %struct.accounting, ptr %242, i64 0, i32 2, !dbg !701
  %255 = load i32, ptr %254, align 8, !dbg !702, !tbaa !703
  %256 = add i32 %255, 1, !dbg !702
  store i32 %256, ptr %254, align 8, !dbg !702, !tbaa !703
  %257 = call i64 inttoptr (i64 2 to ptr)(ptr noundef nonnull @accounting_map, ptr noundef nonnull %5, ptr noundef nonnull %242, i64 noundef 0) #6, !dbg !704
  br label %258, !dbg !705

258:                                              ; preds = %31, %86, %16, %241, %244
  %259 = phi i32 [ 2, %244 ], [ 2, %241 ], [ 1, %16 ], [ 2, %86 ], [ 2, %31 ], !dbg !292
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %5) #6, !dbg !706
  call void @llvm.lifetime.end.p0(i64 13, ptr nonnull %4) #6, !dbg !706
  ret i32 %259, !dbg !706
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i16 @llvm.bswap.i16(i16) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare void @llvm.dbg.assign(metadata, metadata, metadata, metadata, metadata, metadata) #3

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare void @llvm.dbg.value(metadata, metadata, metadata) #4

; Function Attrs: nounwind memory(none)
declare i1 @llvm.bpf.passthrough.i1.i1(i32, i1) #5

; Function Attrs: nounwind memory(none)
declare i32 @llvm.bpf.passthrough.i32.i32(i32, i32) #5

attributes #0 = { nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #3 = { mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #4 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #5 = { nounwind memory(none) }
attributes #6 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!261, !262, !263, !264, !265}
!llvm.ident = !{!266}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "accounting_map", scope: !2, file: !3, line: 46, type: !247, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C11, file: !3, producer: "Ubuntu clang version 18.1.3 (1ubuntu1)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !52, globals: !148, splitDebugInlining: false, nameTableKind: None)
!3 = !DIFile(filename: "xdp_prog_kern.c", directory: "/home/tung/xdp-prj1/xdp-dt/xdp_prog", checksumkind: CSK_MD5, checksum: "559f172e3b7e9b169b08f049286b91da")
!4 = !{!5, !14, !20}
!5 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "xdp_action", file: !6, line: 6178, baseType: !7, size: 32, elements: !8)
!6 = !DIFile(filename: "../../xdp-program/lib/libbpf/include/uapi/linux/bpf.h", directory: "/home/tung/xdp-prj1/xdp-dt/xdp_prog", checksumkind: CSK_MD5, checksum: "2447059c0e1054ae86f48cc38dd3312d")
!7 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!8 = !{!9, !10, !11, !12, !13}
!9 = !DIEnumerator(name: "XDP_ABORTED", value: 0)
!10 = !DIEnumerator(name: "XDP_DROP", value: 1)
!11 = !DIEnumerator(name: "XDP_PASS", value: 2)
!12 = !DIEnumerator(name: "XDP_TX", value: 3)
!13 = !DIEnumerator(name: "XDP_REDIRECT", value: 4)
!14 = !DICompositeType(tag: DW_TAG_enumeration_type, file: !6, line: 1225, baseType: !7, size: 32, elements: !15)
!15 = !{!16, !17, !18, !19}
!16 = !DIEnumerator(name: "BPF_ANY", value: 0)
!17 = !DIEnumerator(name: "BPF_NOEXIST", value: 1)
!18 = !DIEnumerator(name: "BPF_EXIST", value: 2)
!19 = !DIEnumerator(name: "BPF_F_LOCK", value: 4)
!20 = !DICompositeType(tag: DW_TAG_enumeration_type, file: !21, line: 29, baseType: !7, size: 32, elements: !22)
!21 = !DIFile(filename: "/usr/include/linux/in.h", directory: "", checksumkind: CSK_MD5, checksum: "fcee415bb19db8acb968eeda6f02fa29")
!22 = !{!23, !24, !25, !26, !27, !28, !29, !30, !31, !32, !33, !34, !35, !36, !37, !38, !39, !40, !41, !42, !43, !44, !45, !46, !47, !48, !49, !50, !51}
!23 = !DIEnumerator(name: "IPPROTO_IP", value: 0)
!24 = !DIEnumerator(name: "IPPROTO_ICMP", value: 1)
!25 = !DIEnumerator(name: "IPPROTO_IGMP", value: 2)
!26 = !DIEnumerator(name: "IPPROTO_IPIP", value: 4)
!27 = !DIEnumerator(name: "IPPROTO_TCP", value: 6)
!28 = !DIEnumerator(name: "IPPROTO_EGP", value: 8)
!29 = !DIEnumerator(name: "IPPROTO_PUP", value: 12)
!30 = !DIEnumerator(name: "IPPROTO_UDP", value: 17)
!31 = !DIEnumerator(name: "IPPROTO_IDP", value: 22)
!32 = !DIEnumerator(name: "IPPROTO_TP", value: 29)
!33 = !DIEnumerator(name: "IPPROTO_DCCP", value: 33)
!34 = !DIEnumerator(name: "IPPROTO_IPV6", value: 41)
!35 = !DIEnumerator(name: "IPPROTO_RSVP", value: 46)
!36 = !DIEnumerator(name: "IPPROTO_GRE", value: 47)
!37 = !DIEnumerator(name: "IPPROTO_ESP", value: 50)
!38 = !DIEnumerator(name: "IPPROTO_AH", value: 51)
!39 = !DIEnumerator(name: "IPPROTO_MTP", value: 92)
!40 = !DIEnumerator(name: "IPPROTO_BEETPH", value: 94)
!41 = !DIEnumerator(name: "IPPROTO_ENCAP", value: 98)
!42 = !DIEnumerator(name: "IPPROTO_PIM", value: 103)
!43 = !DIEnumerator(name: "IPPROTO_COMP", value: 108)
!44 = !DIEnumerator(name: "IPPROTO_L2TP", value: 115)
!45 = !DIEnumerator(name: "IPPROTO_SCTP", value: 132)
!46 = !DIEnumerator(name: "IPPROTO_UDPLITE", value: 136)
!47 = !DIEnumerator(name: "IPPROTO_MPLS", value: 137)
!48 = !DIEnumerator(name: "IPPROTO_ETHERNET", value: 143)
!49 = !DIEnumerator(name: "IPPROTO_RAW", value: 255)
!50 = !DIEnumerator(name: "IPPROTO_MPTCP", value: 262)
!51 = !DIEnumerator(name: "IPPROTO_MAX", value: 263)
!52 = !{!53, !54, !55, !58, !91, !116, !84, !117, !138, !146}
!53 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64)
!54 = !DIBasicType(name: "long", size: 64, encoding: DW_ATE_signed)
!55 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u16", file: !56, line: 24, baseType: !57)
!56 = !DIFile(filename: "/usr/include/asm-generic/int-ll64.h", directory: "", checksumkind: CSK_MD5, checksum: "b810f270733e106319b67ef512c6246e")
!57 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!58 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !59, size: 64)
!59 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "iphdr", file: !60, line: 87, size: 160, elements: !61)
!60 = !DIFile(filename: "/usr/include/linux/ip.h", directory: "", checksumkind: CSK_MD5, checksum: "149778ace30a1ff208adc8783fd04b29")
!61 = !{!62, !65, !66, !67, !70, !71, !72, !73, !74, !76}
!62 = !DIDerivedType(tag: DW_TAG_member, name: "ihl", scope: !59, file: !60, line: 89, baseType: !63, size: 4, flags: DIFlagBitField, extraData: i64 0)
!63 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u8", file: !56, line: 21, baseType: !64)
!64 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!65 = !DIDerivedType(tag: DW_TAG_member, name: "version", scope: !59, file: !60, line: 90, baseType: !63, size: 4, offset: 4, flags: DIFlagBitField, extraData: i64 0)
!66 = !DIDerivedType(tag: DW_TAG_member, name: "tos", scope: !59, file: !60, line: 97, baseType: !63, size: 8, offset: 8)
!67 = !DIDerivedType(tag: DW_TAG_member, name: "tot_len", scope: !59, file: !60, line: 98, baseType: !68, size: 16, offset: 16)
!68 = !DIDerivedType(tag: DW_TAG_typedef, name: "__be16", file: !69, line: 32, baseType: !55)
!69 = !DIFile(filename: "/usr/include/linux/types.h", directory: "", checksumkind: CSK_MD5, checksum: "bf9fbc0e8f60927fef9d8917535375a6")
!70 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !59, file: !60, line: 99, baseType: !68, size: 16, offset: 32)
!71 = !DIDerivedType(tag: DW_TAG_member, name: "frag_off", scope: !59, file: !60, line: 100, baseType: !68, size: 16, offset: 48)
!72 = !DIDerivedType(tag: DW_TAG_member, name: "ttl", scope: !59, file: !60, line: 101, baseType: !63, size: 8, offset: 64)
!73 = !DIDerivedType(tag: DW_TAG_member, name: "protocol", scope: !59, file: !60, line: 102, baseType: !63, size: 8, offset: 72)
!74 = !DIDerivedType(tag: DW_TAG_member, name: "check", scope: !59, file: !60, line: 103, baseType: !75, size: 16, offset: 80)
!75 = !DIDerivedType(tag: DW_TAG_typedef, name: "__sum16", file: !69, line: 38, baseType: !55)
!76 = !DIDerivedType(tag: DW_TAG_member, scope: !59, file: !60, line: 104, baseType: !77, size: 64, offset: 96)
!77 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !59, file: !60, line: 104, size: 64, elements: !78)
!78 = !{!79, !86}
!79 = !DIDerivedType(tag: DW_TAG_member, scope: !77, file: !60, line: 104, baseType: !80, size: 64)
!80 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !77, file: !60, line: 104, size: 64, elements: !81)
!81 = !{!82, !85}
!82 = !DIDerivedType(tag: DW_TAG_member, name: "saddr", scope: !80, file: !60, line: 104, baseType: !83, size: 32)
!83 = !DIDerivedType(tag: DW_TAG_typedef, name: "__be32", file: !69, line: 34, baseType: !84)
!84 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u32", file: !56, line: 27, baseType: !7)
!85 = !DIDerivedType(tag: DW_TAG_member, name: "daddr", scope: !80, file: !60, line: 104, baseType: !83, size: 32, offset: 32)
!86 = !DIDerivedType(tag: DW_TAG_member, name: "addrs", scope: !77, file: !60, line: 104, baseType: !87, size: 64)
!87 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !77, file: !60, line: 104, size: 64, elements: !88)
!88 = !{!89, !90}
!89 = !DIDerivedType(tag: DW_TAG_member, name: "saddr", scope: !87, file: !60, line: 104, baseType: !83, size: 32)
!90 = !DIDerivedType(tag: DW_TAG_member, name: "daddr", scope: !87, file: !60, line: 104, baseType: !83, size: 32, offset: 32)
!91 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !92, size: 64)
!92 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "icmphdr", file: !93, line: 89, size: 64, elements: !94)
!93 = !DIFile(filename: "../../xdp-program/lib/xdp-tools/headers/linux/icmp.h", directory: "/home/tung/xdp-prj1/xdp-dt/xdp_prog", checksumkind: CSK_MD5, checksum: "ec4fc53f3d0c6471c05ebd35ae4bb8e4")
!94 = !{!95, !96, !97, !98}
!95 = !DIDerivedType(tag: DW_TAG_member, name: "type", scope: !92, file: !93, line: 90, baseType: !63, size: 8)
!96 = !DIDerivedType(tag: DW_TAG_member, name: "code", scope: !92, file: !93, line: 91, baseType: !63, size: 8, offset: 8)
!97 = !DIDerivedType(tag: DW_TAG_member, name: "checksum", scope: !92, file: !93, line: 92, baseType: !75, size: 16, offset: 16)
!98 = !DIDerivedType(tag: DW_TAG_member, name: "un", scope: !92, file: !93, line: 104, baseType: !99, size: 32, offset: 32)
!99 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !92, file: !93, line: 93, size: 32, elements: !100)
!100 = !{!101, !106, !107, !112}
!101 = !DIDerivedType(tag: DW_TAG_member, name: "echo", scope: !99, file: !93, line: 97, baseType: !102, size: 32)
!102 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !99, file: !93, line: 94, size: 32, elements: !103)
!103 = !{!104, !105}
!104 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !102, file: !93, line: 95, baseType: !68, size: 16)
!105 = !DIDerivedType(tag: DW_TAG_member, name: "sequence", scope: !102, file: !93, line: 96, baseType: !68, size: 16, offset: 16)
!106 = !DIDerivedType(tag: DW_TAG_member, name: "gateway", scope: !99, file: !93, line: 98, baseType: !83, size: 32)
!107 = !DIDerivedType(tag: DW_TAG_member, name: "frag", scope: !99, file: !93, line: 102, baseType: !108, size: 32)
!108 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !99, file: !93, line: 99, size: 32, elements: !109)
!109 = !{!110, !111}
!110 = !DIDerivedType(tag: DW_TAG_member, name: "__unused", scope: !108, file: !93, line: 100, baseType: !68, size: 16)
!111 = !DIDerivedType(tag: DW_TAG_member, name: "mtu", scope: !108, file: !93, line: 101, baseType: !68, size: 16, offset: 16)
!112 = !DIDerivedType(tag: DW_TAG_member, name: "reserved", scope: !99, file: !93, line: 103, baseType: !113, size: 32)
!113 = !DICompositeType(tag: DW_TAG_array_type, baseType: !63, size: 32, elements: !114)
!114 = !{!115}
!115 = !DISubrange(count: 4)
!116 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !63, size: 64)
!117 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !118, size: 64)
!118 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "tcphdr", file: !119, line: 25, size: 160, elements: !120)
!119 = !DIFile(filename: "/usr/include/linux/tcp.h", directory: "", checksumkind: CSK_MD5, checksum: "bd53e42c49642a86fd7da9761b6f86eb")
!120 = !{!121, !122, !123, !124, !125, !126, !127, !128, !129, !130, !131, !132, !133, !134, !135, !136, !137}
!121 = !DIDerivedType(tag: DW_TAG_member, name: "source", scope: !118, file: !119, line: 26, baseType: !68, size: 16)
!122 = !DIDerivedType(tag: DW_TAG_member, name: "dest", scope: !118, file: !119, line: 27, baseType: !68, size: 16, offset: 16)
!123 = !DIDerivedType(tag: DW_TAG_member, name: "seq", scope: !118, file: !119, line: 28, baseType: !83, size: 32, offset: 32)
!124 = !DIDerivedType(tag: DW_TAG_member, name: "ack_seq", scope: !118, file: !119, line: 29, baseType: !83, size: 32, offset: 64)
!125 = !DIDerivedType(tag: DW_TAG_member, name: "res1", scope: !118, file: !119, line: 31, baseType: !55, size: 4, offset: 96, flags: DIFlagBitField, extraData: i64 96)
!126 = !DIDerivedType(tag: DW_TAG_member, name: "doff", scope: !118, file: !119, line: 32, baseType: !55, size: 4, offset: 100, flags: DIFlagBitField, extraData: i64 96)
!127 = !DIDerivedType(tag: DW_TAG_member, name: "fin", scope: !118, file: !119, line: 33, baseType: !55, size: 1, offset: 104, flags: DIFlagBitField, extraData: i64 96)
!128 = !DIDerivedType(tag: DW_TAG_member, name: "syn", scope: !118, file: !119, line: 34, baseType: !55, size: 1, offset: 105, flags: DIFlagBitField, extraData: i64 96)
!129 = !DIDerivedType(tag: DW_TAG_member, name: "rst", scope: !118, file: !119, line: 35, baseType: !55, size: 1, offset: 106, flags: DIFlagBitField, extraData: i64 96)
!130 = !DIDerivedType(tag: DW_TAG_member, name: "psh", scope: !118, file: !119, line: 36, baseType: !55, size: 1, offset: 107, flags: DIFlagBitField, extraData: i64 96)
!131 = !DIDerivedType(tag: DW_TAG_member, name: "ack", scope: !118, file: !119, line: 37, baseType: !55, size: 1, offset: 108, flags: DIFlagBitField, extraData: i64 96)
!132 = !DIDerivedType(tag: DW_TAG_member, name: "urg", scope: !118, file: !119, line: 38, baseType: !55, size: 1, offset: 109, flags: DIFlagBitField, extraData: i64 96)
!133 = !DIDerivedType(tag: DW_TAG_member, name: "ece", scope: !118, file: !119, line: 39, baseType: !55, size: 1, offset: 110, flags: DIFlagBitField, extraData: i64 96)
!134 = !DIDerivedType(tag: DW_TAG_member, name: "cwr", scope: !118, file: !119, line: 40, baseType: !55, size: 1, offset: 111, flags: DIFlagBitField, extraData: i64 96)
!135 = !DIDerivedType(tag: DW_TAG_member, name: "window", scope: !118, file: !119, line: 55, baseType: !68, size: 16, offset: 112)
!136 = !DIDerivedType(tag: DW_TAG_member, name: "check", scope: !118, file: !119, line: 56, baseType: !75, size: 16, offset: 128)
!137 = !DIDerivedType(tag: DW_TAG_member, name: "urg_ptr", scope: !118, file: !119, line: 57, baseType: !68, size: 16, offset: 144)
!138 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !139, size: 64)
!139 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "udphdr", file: !140, line: 23, size: 64, elements: !141)
!140 = !DIFile(filename: "/usr/include/linux/udp.h", directory: "", checksumkind: CSK_MD5, checksum: "53c0d42e1bf6d93b39151764be2d20fb")
!141 = !{!142, !143, !144, !145}
!142 = !DIDerivedType(tag: DW_TAG_member, name: "source", scope: !139, file: !140, line: 24, baseType: !68, size: 16)
!143 = !DIDerivedType(tag: DW_TAG_member, name: "dest", scope: !139, file: !140, line: 25, baseType: !68, size: 16, offset: 16)
!144 = !DIDerivedType(tag: DW_TAG_member, name: "len", scope: !139, file: !140, line: 26, baseType: !68, size: 16, offset: 32)
!145 = !DIDerivedType(tag: DW_TAG_member, name: "check", scope: !139, file: !140, line: 27, baseType: !75, size: 16, offset: 48)
!146 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u64", file: !56, line: 31, baseType: !147)
!147 = !DIBasicType(name: "unsigned long long", size: 64, encoding: DW_ATE_unsigned)
!148 = !{!149, !153, !196, !0, !229, !237, !242}
!149 = !DIGlobalVariableExpression(var: !150, expr: !DIExpression())
!150 = distinct !DIGlobalVariable(name: "_license", scope: !2, file: !3, line: 273, type: !151, isLocal: false, isDefinition: true)
!151 = !DICompositeType(tag: DW_TAG_array_type, baseType: !152, size: 32, elements: !114)
!152 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!153 = !DIGlobalVariableExpression(var: !154, expr: !DIExpression())
!154 = distinct !DIGlobalVariable(name: "dt_map", scope: !2, file: !3, line: 29, type: !155, isLocal: false, isDefinition: true)
!155 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !3, line: 23, size: 256, elements: !156)
!156 = !{!157, !163, !168, !170}
!157 = !DIDerivedType(tag: DW_TAG_member, name: "type", scope: !155, file: !3, line: 24, baseType: !158, size: 64)
!158 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !159, size: 64)
!159 = !DICompositeType(tag: DW_TAG_array_type, baseType: !160, size: 64, elements: !161)
!160 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!161 = !{!162}
!162 = !DISubrange(count: 2)
!163 = !DIDerivedType(tag: DW_TAG_member, name: "max_entries", scope: !155, file: !3, line: 25, baseType: !164, size: 64, offset: 64)
!164 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !165, size: 64)
!165 = !DICompositeType(tag: DW_TAG_array_type, baseType: !160, size: 32, elements: !166)
!166 = !{!167}
!167 = !DISubrange(count: 1)
!168 = !DIDerivedType(tag: DW_TAG_member, name: "key", scope: !155, file: !3, line: 26, baseType: !169, size: 64, offset: 128)
!169 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !84, size: 64)
!170 = !DIDerivedType(tag: DW_TAG_member, name: "value", scope: !155, file: !3, line: 27, baseType: !171, size: 64, offset: 192)
!171 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !172, size: 64)
!172 = !DIDerivedType(tag: DW_TAG_typedef, name: "dt_tree", file: !173, line: 73, baseType: !174)
!173 = !DIFile(filename: "./common_kern_user.h", directory: "/home/tung/xdp-prj1/xdp-dt/xdp_prog", checksumkind: CSK_MD5, checksum: "e6bda3be3981a72bc0ff7021595386c2")
!174 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !173, line: 68, size: 1280832, elements: !175)
!175 = !{!176, !190, !191, !195}
!176 = !DIDerivedType(tag: DW_TAG_member, name: "nodes", scope: !174, file: !173, line: 69, baseType: !177, size: 1280000)
!177 = !DICompositeType(tag: DW_TAG_array_type, baseType: !178, size: 1280000, elements: !188)
!178 = !DIDerivedType(tag: DW_TAG_typedef, name: "dt_node", file: !173, line: 65, baseType: !179)
!179 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !173, line: 58, size: 256, elements: !180)
!180 = !{!181, !182, !183, !185, !186, !187}
!181 = !DIDerivedType(tag: DW_TAG_member, name: "left_idx", scope: !179, file: !173, line: 59, baseType: !160, size: 32)
!182 = !DIDerivedType(tag: DW_TAG_member, name: "right_idx", scope: !179, file: !173, line: 60, baseType: !160, size: 32, offset: 32)
!183 = !DIDerivedType(tag: DW_TAG_member, name: "split_value", scope: !179, file: !173, line: 61, baseType: !184, size: 64, offset: 64)
!184 = !DIDerivedType(tag: DW_TAG_typedef, name: "fixed", file: !173, line: 25, baseType: !146)
!185 = !DIDerivedType(tag: DW_TAG_member, name: "feature_idx", scope: !179, file: !173, line: 62, baseType: !160, size: 32, offset: 128)
!186 = !DIDerivedType(tag: DW_TAG_member, name: "is_leaf", scope: !179, file: !173, line: 63, baseType: !84, size: 32, offset: 160)
!187 = !DIDerivedType(tag: DW_TAG_member, name: "label", scope: !179, file: !173, line: 64, baseType: !160, size: 32, offset: 192)
!188 = !{!189}
!189 = !DISubrange(count: 5000)
!190 = !DIDerivedType(tag: DW_TAG_member, name: "num_nodes", scope: !174, file: !173, line: 70, baseType: !84, size: 32, offset: 1280000)
!191 = !DIDerivedType(tag: DW_TAG_member, name: "min_vals", scope: !174, file: !173, line: 71, baseType: !192, size: 384, offset: 1280064)
!192 = !DICompositeType(tag: DW_TAG_array_type, baseType: !184, size: 384, elements: !193)
!193 = !{!194}
!194 = !DISubrange(count: 6)
!195 = !DIDerivedType(tag: DW_TAG_member, name: "max_vals", scope: !174, file: !173, line: 72, baseType: !192, size: 384, offset: 1280448)
!196 = !DIGlobalVariableExpression(var: !197, expr: !DIExpression())
!197 = distinct !DIGlobalVariable(name: "xdp_flow_tracking", scope: !2, file: !3, line: 38, type: !198, isLocal: false, isDefinition: true)
!198 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !3, line: 32, size: 256, elements: !199)
!199 = !{!200, !201, !210, !224}
!200 = !DIDerivedType(tag: DW_TAG_member, name: "type", scope: !198, file: !3, line: 33, baseType: !164, size: 64)
!201 = !DIDerivedType(tag: DW_TAG_member, name: "key", scope: !198, file: !3, line: 34, baseType: !202, size: 64, offset: 64)
!202 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !203, size: 64)
!203 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "flow_key", file: !173, line: 28, size: 104, elements: !204)
!204 = !{!205, !206, !207, !208, !209}
!205 = !DIDerivedType(tag: DW_TAG_member, name: "src_ip", scope: !203, file: !173, line: 29, baseType: !84, size: 32)
!206 = !DIDerivedType(tag: DW_TAG_member, name: "src_port", scope: !203, file: !173, line: 30, baseType: !55, size: 16, offset: 32)
!207 = !DIDerivedType(tag: DW_TAG_member, name: "dst_ip", scope: !203, file: !173, line: 31, baseType: !84, size: 32, offset: 48)
!208 = !DIDerivedType(tag: DW_TAG_member, name: "dst_port", scope: !203, file: !173, line: 32, baseType: !55, size: 16, offset: 80)
!209 = !DIDerivedType(tag: DW_TAG_member, name: "proto", scope: !203, file: !173, line: 33, baseType: !63, size: 8, offset: 96)
!210 = !DIDerivedType(tag: DW_TAG_member, name: "value", scope: !198, file: !3, line: 35, baseType: !211, size: 64, offset: 128)
!211 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !212, size: 64)
!212 = !DIDerivedType(tag: DW_TAG_typedef, name: "data_point", file: !173, line: 47, baseType: !213)
!213 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !173, line: 37, size: 768, elements: !214)
!214 = !{!215, !216, !217, !218, !219, !220, !221, !222, !223}
!215 = !DIDerivedType(tag: DW_TAG_member, name: "start_ts", scope: !213, file: !173, line: 38, baseType: !146, size: 64)
!216 = !DIDerivedType(tag: DW_TAG_member, name: "last_seen", scope: !213, file: !173, line: 39, baseType: !146, size: 64, offset: 64)
!217 = !DIDerivedType(tag: DW_TAG_member, name: "min_IAT", scope: !213, file: !173, line: 40, baseType: !146, size: 64, offset: 128)
!218 = !DIDerivedType(tag: DW_TAG_member, name: "total_pkts", scope: !213, file: !173, line: 41, baseType: !84, size: 32, offset: 192)
!219 = !DIDerivedType(tag: DW_TAG_member, name: "max_pkt_len", scope: !213, file: !173, line: 42, baseType: !84, size: 32, offset: 224)
!220 = !DIDerivedType(tag: DW_TAG_member, name: "min_pkt_len", scope: !213, file: !173, line: 43, baseType: !84, size: 32, offset: 256)
!221 = !DIDerivedType(tag: DW_TAG_member, name: "total_bytes", scope: !213, file: !173, line: 44, baseType: !84, size: 32, offset: 288)
!222 = !DIDerivedType(tag: DW_TAG_member, name: "features", scope: !213, file: !173, line: 45, baseType: !192, size: 384, offset: 320)
!223 = !DIDerivedType(tag: DW_TAG_member, name: "label", scope: !213, file: !173, line: 46, baseType: !160, size: 32, offset: 704)
!224 = !DIDerivedType(tag: DW_TAG_member, name: "max_entries", scope: !198, file: !3, line: 36, baseType: !225, size: 64, offset: 192)
!225 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !226, size: 64)
!226 = !DICompositeType(tag: DW_TAG_array_type, baseType: !160, size: 320000, elements: !227)
!227 = !{!228}
!228 = !DISubrange(count: 10000)
!229 = !DIGlobalVariableExpression(var: !230, expr: !DIExpression(DW_OP_constu, 1, DW_OP_stack_value))
!230 = distinct !DIGlobalVariable(name: "bpf_map_lookup_elem", scope: !2, file: !231, line: 56, type: !232, isLocal: true, isDefinition: true)
!231 = !DIFile(filename: "../lib/install/include/bpf/bpf_helper_defs.h", directory: "/home/tung/xdp-prj1/xdp-dt/xdp_prog", checksumkind: CSK_MD5, checksum: "7422ca06c9dc86eba2f268a57d8acf2f")
!232 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !233, size: 64)
!233 = !DISubroutineType(types: !234)
!234 = !{!53, !53, !235}
!235 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !236, size: 64)
!236 = !DIDerivedType(tag: DW_TAG_const_type, baseType: null)
!237 = !DIGlobalVariableExpression(var: !238, expr: !DIExpression(DW_OP_constu, 5, DW_OP_stack_value))
!238 = distinct !DIGlobalVariable(name: "bpf_ktime_get_ns", scope: !2, file: !231, line: 114, type: !239, isLocal: true, isDefinition: true)
!239 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !240, size: 64)
!240 = !DISubroutineType(types: !241)
!241 = !{!146}
!242 = !DIGlobalVariableExpression(var: !243, expr: !DIExpression(DW_OP_constu, 2, DW_OP_stack_value))
!243 = distinct !DIGlobalVariable(name: "bpf_map_update_elem", scope: !2, file: !231, line: 78, type: !244, isLocal: true, isDefinition: true)
!244 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !245, size: 64)
!245 = !DISubroutineType(types: !246)
!246 = !{!54, !53, !235, !235, !146}
!247 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !3, line: 40, size: 256, elements: !248)
!248 = !{!249, !250, !251, !260}
!249 = !DIDerivedType(tag: DW_TAG_member, name: "type", scope: !247, file: !3, line: 41, baseType: !158, size: 64)
!250 = !DIDerivedType(tag: DW_TAG_member, name: "key", scope: !247, file: !3, line: 42, baseType: !169, size: 64, offset: 64)
!251 = !DIDerivedType(tag: DW_TAG_member, name: "value", scope: !247, file: !3, line: 43, baseType: !252, size: 64, offset: 128)
!252 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !253, size: 64)
!253 = !DIDerivedType(tag: DW_TAG_typedef, name: "accounting", file: !173, line: 55, baseType: !254)
!254 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !173, line: 50, size: 192, elements: !255)
!255 = !{!256, !257, !258, !259}
!256 = !DIDerivedType(tag: DW_TAG_member, name: "time_in", scope: !254, file: !173, line: 51, baseType: !146, size: 64)
!257 = !DIDerivedType(tag: DW_TAG_member, name: "proc_time", scope: !254, file: !173, line: 52, baseType: !146, size: 64, offset: 64)
!258 = !DIDerivedType(tag: DW_TAG_member, name: "total_pkts", scope: !254, file: !173, line: 53, baseType: !84, size: 32, offset: 128)
!259 = !DIDerivedType(tag: DW_TAG_member, name: "total_bytes", scope: !254, file: !173, line: 54, baseType: !84, size: 32, offset: 160)
!260 = !DIDerivedType(tag: DW_TAG_member, name: "max_entries", scope: !247, file: !3, line: 44, baseType: !164, size: 64, offset: 192)
!261 = !{i32 7, !"Dwarf Version", i32 5}
!262 = !{i32 2, !"Debug Info Version", i32 3}
!263 = !{i32 1, !"wchar_size", i32 4}
!264 = !{i32 7, !"frame-pointer", i32 2}
!265 = !{i32 7, !"debug-info-assignment-tracking", i1 true}
!266 = !{!"Ubuntu clang version 18.1.3 (1ubuntu1)"}
!267 = distinct !DISubprogram(name: "xdp_anomaly_detector", scope: !3, file: !3, line: 241, type: !268, scopeLine: 242, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !279)
!268 = !DISubroutineType(types: !269)
!269 = !{!160, !270}
!270 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !271, size: 64)
!271 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "xdp_md", file: !6, line: 6189, size: 192, elements: !272)
!272 = !{!273, !274, !275, !276, !277, !278}
!273 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !271, file: !6, line: 6190, baseType: !84, size: 32)
!274 = !DIDerivedType(tag: DW_TAG_member, name: "data_end", scope: !271, file: !6, line: 6191, baseType: !84, size: 32, offset: 32)
!275 = !DIDerivedType(tag: DW_TAG_member, name: "data_meta", scope: !271, file: !6, line: 6192, baseType: !84, size: 32, offset: 64)
!276 = !DIDerivedType(tag: DW_TAG_member, name: "ingress_ifindex", scope: !271, file: !6, line: 6194, baseType: !84, size: 32, offset: 96)
!277 = !DIDerivedType(tag: DW_TAG_member, name: "rx_queue_index", scope: !271, file: !6, line: 6195, baseType: !84, size: 32, offset: 128)
!278 = !DIDerivedType(tag: DW_TAG_member, name: "egress_ifindex", scope: !271, file: !6, line: 6197, baseType: !84, size: 32, offset: 160)
!279 = !{!280, !281, !282, !283, !284, !285, !286}
!280 = !DILocalVariable(name: "ctx", arg: 1, scope: !267, file: !3, line: 241, type: !270)
!281 = !DILocalVariable(name: "key", scope: !267, file: !3, line: 243, type: !203)
!282 = !DILocalVariable(name: "pkt_len", scope: !267, file: !3, line: 244, type: !146)
!283 = !DILocalVariable(name: "key_ac", scope: !267, file: !3, line: 245, type: !84)
!284 = !DILocalVariable(name: "ret", scope: !267, file: !3, line: 248, type: !160)
!285 = !DILocalVariable(name: "ac", scope: !267, file: !3, line: 260, type: !252)
!286 = !DILocalVariable(name: "time_out", scope: !287, file: !3, line: 263, type: !146)
!287 = distinct !DILexicalBlock(scope: !288, file: !3, line: 262, column: 13)
!288 = distinct !DILexicalBlock(scope: !267, file: !3, line: 262, column: 9)
!289 = distinct !DIAssignID()
!290 = distinct !DIAssignID()
!291 = distinct !DIAssignID()
!292 = !DILocation(line: 0, scope: !267)
!293 = distinct !DIAssignID()
!294 = !DILocation(line: 243, column: 5, scope: !267)
!295 = !DILocation(line: 243, column: 21, scope: !267)
!296 = distinct !DIAssignID()
!297 = distinct !DIAssignID()
!298 = distinct !DIAssignID()
!299 = !DILocation(line: 245, column: 5, scope: !267)
!300 = !DILocation(line: 245, column: 11, scope: !267)
!301 = !{!302, !302, i64 0}
!302 = !{!"int", !303, i64 0}
!303 = !{!"omnipotent char", !304, i64 0}
!304 = !{!"Simple C/C++ TBAA"}
!305 = distinct !DIAssignID()
!306 = !DILocalVariable(name: "ctx", arg: 1, scope: !307, file: !3, line: 49, type: !270)
!307 = distinct !DISubprogram(name: "parse_packet_get_data", scope: !3, file: !3, line: 49, type: !308, scopeLine: 52, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !311)
!308 = !DISubroutineType(types: !309)
!309 = !{!160, !270, !202, !310}
!310 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !146, size: 64)
!311 = !{!306, !312, !313, !314, !315, !316, !325, !326, !329, !330, !331, !334}
!312 = !DILocalVariable(name: "key", arg: 2, scope: !307, file: !3, line: 50, type: !202)
!313 = !DILocalVariable(name: "pkt_len", arg: 3, scope: !307, file: !3, line: 51, type: !310)
!314 = !DILocalVariable(name: "data_end", scope: !307, file: !3, line: 53, type: !53)
!315 = !DILocalVariable(name: "data", scope: !307, file: !3, line: 54, type: !53)
!316 = !DILocalVariable(name: "eth", scope: !307, file: !3, line: 55, type: !317)
!317 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !318, size: 64)
!318 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ethhdr", file: !319, line: 173, size: 112, elements: !320)
!319 = !DIFile(filename: "/usr/include/linux/if_ether.h", directory: "", checksumkind: CSK_MD5, checksum: "163f54fb1af2e21fea410f14eb18fa76")
!320 = !{!321, !323, !324}
!321 = !DIDerivedType(tag: DW_TAG_member, name: "h_dest", scope: !318, file: !319, line: 174, baseType: !322, size: 48)
!322 = !DICompositeType(tag: DW_TAG_array_type, baseType: !64, size: 48, elements: !193)
!323 = !DIDerivedType(tag: DW_TAG_member, name: "h_source", scope: !318, file: !319, line: 175, baseType: !322, size: 48, offset: 48)
!324 = !DIDerivedType(tag: DW_TAG_member, name: "h_proto", scope: !318, file: !319, line: 176, baseType: !68, size: 16, offset: 96)
!325 = !DILocalVariable(name: "iph", scope: !307, file: !3, line: 66, type: !58)
!326 = !DILocalVariable(name: "icmp", scope: !327, file: !3, line: 75, type: !91)
!327 = distinct !DILexicalBlock(scope: !328, file: !3, line: 74, column: 40)
!328 = distinct !DILexicalBlock(scope: !307, file: !3, line: 74, column: 9)
!329 = !DILocalVariable(name: "src", scope: !327, file: !3, line: 78, type: !84)
!330 = !DILocalVariable(name: "dst", scope: !327, file: !3, line: 79, type: !84)
!331 = !DILocalVariable(name: "tcph", scope: !332, file: !3, line: 87, type: !117)
!332 = distinct !DILexicalBlock(scope: !333, file: !3, line: 86, column: 39)
!333 = distinct !DILexicalBlock(scope: !307, file: !3, line: 86, column: 9)
!334 = !DILocalVariable(name: "udph", scope: !335, file: !3, line: 92, type: !138)
!335 = distinct !DILexicalBlock(scope: !336, file: !3, line: 91, column: 46)
!336 = distinct !DILexicalBlock(scope: !333, file: !3, line: 91, column: 16)
!337 = !DILocation(line: 0, scope: !307, inlinedAt: !338)
!338 = distinct !DILocation(line: 248, column: 15, scope: !267)
!339 = !DILocation(line: 53, column: 41, scope: !307, inlinedAt: !338)
!340 = !{!341, !302, i64 4}
!341 = !{!"xdp_md", !302, i64 0, !302, i64 4, !302, i64 8, !302, i64 12, !302, i64 16, !302, i64 20}
!342 = !DILocation(line: 53, column: 30, scope: !307, inlinedAt: !338)
!343 = !DILocation(line: 53, column: 22, scope: !307, inlinedAt: !338)
!344 = !DILocation(line: 54, column: 41, scope: !307, inlinedAt: !338)
!345 = !{!341, !302, i64 0}
!346 = !DILocation(line: 54, column: 30, scope: !307, inlinedAt: !338)
!347 = !DILocation(line: 54, column: 22, scope: !307, inlinedAt: !338)
!348 = !DILocation(line: 57, column: 22, scope: !349, inlinedAt: !338)
!349 = distinct !DILexicalBlock(scope: !307, file: !3, line: 57, column: 9)
!350 = !DILocation(line: 57, column: 27, scope: !349, inlinedAt: !338)
!351 = !DILocation(line: 57, column: 9, scope: !307, inlinedAt: !338)
!352 = !DILocation(line: 60, column: 14, scope: !353, inlinedAt: !338)
!353 = distinct !DILexicalBlock(scope: !307, file: !3, line: 60, column: 9)
!354 = !{!355, !356, i64 12}
!355 = !{!"ethhdr", !303, i64 0, !303, i64 6, !356, i64 12}
!356 = !{!"short", !303, i64 0}
!357 = !DILocation(line: 60, column: 9, scope: !307, inlinedAt: !338)
!358 = !DILocation(line: 67, column: 22, scope: !359, inlinedAt: !338)
!359 = distinct !DILexicalBlock(scope: !307, file: !3, line: 67, column: 9)
!360 = !DILocation(line: 67, column: 27, scope: !359, inlinedAt: !338)
!361 = !DILocation(line: 67, column: 9, scope: !307, inlinedAt: !338)
!362 = !DILocation(line: 70, column: 24, scope: !307, inlinedAt: !338)
!363 = !{!303, !303, i64 0}
!364 = !DILocation(line: 70, column: 17, scope: !307, inlinedAt: !338)
!365 = !{!366, !302, i64 0}
!366 = !{!"flow_key", !302, i64 0, !356, i64 4, !302, i64 6, !356, i64 10, !303, i64 12}
!367 = distinct !DIAssignID()
!368 = !DILocation(line: 71, column: 24, scope: !307, inlinedAt: !338)
!369 = !DILocation(line: 71, column: 10, scope: !307, inlinedAt: !338)
!370 = !DILocation(line: 71, column: 17, scope: !307, inlinedAt: !338)
!371 = !{!366, !302, i64 6}
!372 = distinct !DIAssignID()
!373 = !DILocation(line: 72, column: 24, scope: !307, inlinedAt: !338)
!374 = !{!375, !303, i64 9}
!375 = !{!"iphdr", !303, i64 0, !303, i64 0, !303, i64 1, !356, i64 2, !356, i64 4, !356, i64 6, !303, i64 8, !303, i64 9, !356, i64 10, !303, i64 12}
!376 = !DILocation(line: 72, column: 10, scope: !307, inlinedAt: !338)
!377 = !DILocation(line: 72, column: 17, scope: !307, inlinedAt: !338)
!378 = !{!366, !303, i64 12}
!379 = distinct !DIAssignID()
!380 = !DILocation(line: 74, column: 9, scope: !307, inlinedAt: !338)
!381 = !DILocation(line: 75, column: 71, scope: !327, inlinedAt: !338)
!382 = !DILocation(line: 75, column: 75, scope: !327, inlinedAt: !338)
!383 = !DILocation(line: 75, column: 63, scope: !327, inlinedAt: !338)
!384 = !DILocation(line: 0, scope: !327, inlinedAt: !338)
!385 = !DILocation(line: 76, column: 27, scope: !386, inlinedAt: !338)
!386 = distinct !DILexicalBlock(scope: !327, file: !3, line: 76, column: 13)
!387 = !DILocation(line: 76, column: 32, scope: !386, inlinedAt: !338)
!388 = !DILocation(line: 76, column: 13, scope: !327, inlinedAt: !338)
!389 = !DILocation(line: 80, column: 18, scope: !390, inlinedAt: !338)
!390 = distinct !DILexicalBlock(scope: !327, file: !3, line: 80, column: 13)
!391 = !DILocation(line: 80, column: 32, scope: !390, inlinedAt: !338)
!392 = !DILocation(line: 80, column: 62, scope: !390, inlinedAt: !338)
!393 = !{!394, !303, i64 0}
!394 = !{!"icmphdr", !303, i64 0, !303, i64 1, !356, i64 2, !303, i64 4}
!395 = !DILocation(line: 80, column: 67, scope: !390, inlinedAt: !338)
!396 = !DILocation(line: 80, column: 73, scope: !390, inlinedAt: !338)
!397 = !DILocation(line: 81, column: 18, scope: !390, inlinedAt: !338)
!398 = !DILocation(line: 81, column: 32, scope: !390, inlinedAt: !338)
!399 = !DILocation(line: 81, column: 62, scope: !390, inlinedAt: !338)
!400 = !DILocation(line: 81, column: 67, scope: !390, inlinedAt: !338)
!401 = !DILocation(line: 80, column: 13, scope: !327, inlinedAt: !338)
!402 = !DILocation(line: 87, column: 69, scope: !332, inlinedAt: !338)
!403 = !DILocation(line: 87, column: 73, scope: !332, inlinedAt: !338)
!404 = !DILocation(line: 87, column: 61, scope: !332, inlinedAt: !338)
!405 = !DILocation(line: 0, scope: !332, inlinedAt: !338)
!406 = !DILocation(line: 88, column: 27, scope: !407, inlinedAt: !338)
!407 = distinct !DILexicalBlock(scope: !332, file: !3, line: 88, column: 13)
!408 = !DILocation(line: 88, column: 32, scope: !407, inlinedAt: !338)
!409 = !DILocation(line: 88, column: 13, scope: !332, inlinedAt: !338)
!410 = distinct !DIAssignID()
!411 = !DILocation(line: 90, column: 31, scope: !332, inlinedAt: !338)
!412 = distinct !DIAssignID()
!413 = !DILocation(line: 92, column: 69, scope: !335, inlinedAt: !338)
!414 = !DILocation(line: 92, column: 73, scope: !335, inlinedAt: !338)
!415 = !DILocation(line: 92, column: 61, scope: !335, inlinedAt: !338)
!416 = !DILocation(line: 0, scope: !335, inlinedAt: !338)
!417 = !DILocation(line: 93, column: 27, scope: !418, inlinedAt: !338)
!418 = distinct !DILexicalBlock(scope: !335, file: !3, line: 93, column: 13)
!419 = !DILocation(line: 93, column: 32, scope: !418, inlinedAt: !338)
!420 = !DILocation(line: 93, column: 13, scope: !335, inlinedAt: !338)
!421 = distinct !DIAssignID()
!422 = !DILocation(line: 95, column: 31, scope: !335, inlinedAt: !338)
!423 = distinct !DIAssignID()
!424 = !DILocation(line: 0, scope: !333, inlinedAt: !338)
!425 = !{!356, !356, i64 0}
!426 = !DILocation(line: 101, column: 21, scope: !307, inlinedAt: !338)
!427 = !DILocation(line: 102, column: 21, scope: !307, inlinedAt: !338)
!428 = !DILocation(line: 101, column: 19, scope: !307, inlinedAt: !338)
!429 = !{!366, !356, i64 4}
!430 = distinct !DIAssignID()
!431 = !DILocation(line: 102, column: 19, scope: !307, inlinedAt: !338)
!432 = !{!366, !356, i64 10}
!433 = distinct !DIAssignID()
!434 = !DILocation(line: 103, column: 41, scope: !307, inlinedAt: !338)
!435 = !DILocation(line: 251, column: 9, scope: !267)
!436 = !DILocalVariable(name: "zero", scope: !437, file: !3, line: 165, type: !212)
!437 = distinct !DILexicalBlock(scope: !438, file: !3, line: 163, column: 14)
!438 = distinct !DILexicalBlock(scope: !439, file: !3, line: 163, column: 9)
!439 = distinct !DISubprogram(name: "update_stats", scope: !3, file: !3, line: 153, type: !440, scopeLine: 155, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !442)
!440 = !DISubroutineType(types: !441)
!441 = !{!160, !202, !270}
!442 = !{!443, !444, !445, !446, !447, !448, !449, !436, !450, !452, !455, !456, !457, !458, !459}
!443 = !DILocalVariable(name: "key", arg: 1, scope: !439, file: !3, line: 153, type: !202)
!444 = !DILocalVariable(name: "ctx", arg: 2, scope: !439, file: !3, line: 154, type: !270)
!445 = !DILocalVariable(name: "ts_ns", scope: !439, file: !3, line: 156, type: !146)
!446 = !DILocalVariable(name: "pkt_len", scope: !439, file: !3, line: 157, type: !146)
!447 = !DILocalVariable(name: "ret", scope: !439, file: !3, line: 159, type: !160)
!448 = !DILocalVariable(name: "is_new_flow", scope: !439, file: !3, line: 160, type: !160)
!449 = !DILocalVariable(name: "dp", scope: !439, file: !3, line: 162, type: !211)
!450 = !DILocalVariable(name: "i", scope: !451, file: !3, line: 175, type: !160)
!451 = distinct !DILexicalBlock(scope: !437, file: !3, line: 175, column: 9)
!452 = !DILocalVariable(name: "iat_ns", scope: !453, file: !3, line: 192, type: !146)
!453 = distinct !DILexicalBlock(scope: !454, file: !3, line: 191, column: 23)
!454 = distinct !DILexicalBlock(scope: !439, file: !3, line: 191, column: 9)
!455 = !DILocalVariable(name: "duration_us", scope: !439, file: !3, line: 209, type: !146)
!456 = !DILocalVariable(name: "iat_us", scope: !439, file: !3, line: 215, type: !146)
!457 = !DILocalVariable(name: "key_dt", scope: !439, file: !3, line: 219, type: !84)
!458 = !DILocalVariable(name: "dt_pr", scope: !439, file: !3, line: 220, type: !171)
!459 = !DILocalVariable(name: "dt_pred", scope: !460, file: !3, line: 224, type: !160)
!460 = distinct !DILexicalBlock(scope: !461, file: !3, line: 223, column: 16)
!461 = distinct !DILexicalBlock(scope: !439, file: !3, line: 223, column: 9)
!462 = !DILocation(line: 0, scope: !437, inlinedAt: !463)
!463 = distinct !DILocation(line: 257, column: 11, scope: !267)
!464 = !DILocation(line: 0, scope: !439, inlinedAt: !463)
!465 = !DILocation(line: 156, column: 19, scope: !439, inlinedAt: !463)
!466 = !DILocation(line: 192, column: 43, scope: !453, inlinedAt: !463)
!467 = !DILocation(line: 157, column: 57, scope: !439, inlinedAt: !463)
!468 = !DILocation(line: 157, column: 46, scope: !439, inlinedAt: !463)
!469 = !DILocation(line: 158, column: 57, scope: !439, inlinedAt: !463)
!470 = !DILocation(line: 158, column: 46, scope: !439, inlinedAt: !463)
!471 = !DILocation(line: 157, column: 67, scope: !439, inlinedAt: !463)
!472 = !DILocation(line: 162, column: 22, scope: !439, inlinedAt: !463)
!473 = !DILocation(line: 163, column: 10, scope: !438, inlinedAt: !463)
!474 = !DILocation(line: 163, column: 9, scope: !439, inlinedAt: !463)
!475 = !DILocation(line: 165, column: 9, scope: !437, inlinedAt: !463)
!476 = !DILocation(line: 165, column: 20, scope: !437, inlinedAt: !463)
!477 = distinct !DIAssignID()
!478 = distinct !DIAssignID()
!479 = !DILocation(line: 166, column: 23, scope: !437, inlinedAt: !463)
!480 = !{!481, !482, i64 0}
!481 = !{!"", !482, i64 0, !482, i64 8, !482, i64 16, !302, i64 24, !302, i64 28, !302, i64 32, !302, i64 36, !303, i64 40, !302, i64 88}
!482 = !{!"long long", !303, i64 0}
!483 = distinct !DIAssignID()
!484 = !DILocation(line: 167, column: 14, scope: !437, inlinedAt: !463)
!485 = !DILocation(line: 167, column: 24, scope: !437, inlinedAt: !463)
!486 = !{!481, !482, i64 8}
!487 = distinct !DIAssignID()
!488 = !DILocation(line: 168, column: 14, scope: !437, inlinedAt: !463)
!489 = !DILocation(line: 168, column: 22, scope: !437, inlinedAt: !463)
!490 = !{!481, !482, i64 16}
!491 = distinct !DIAssignID()
!492 = !DILocation(line: 169, column: 14, scope: !437, inlinedAt: !463)
!493 = !DILocation(line: 169, column: 25, scope: !437, inlinedAt: !463)
!494 = !{!481, !302, i64 24}
!495 = distinct !DIAssignID()
!496 = !DILocation(line: 170, column: 28, scope: !437, inlinedAt: !463)
!497 = !DILocation(line: 170, column: 14, scope: !437, inlinedAt: !463)
!498 = !DILocation(line: 170, column: 26, scope: !437, inlinedAt: !463)
!499 = !{!481, !302, i64 28}
!500 = distinct !DIAssignID()
!501 = !DILocation(line: 171, column: 14, scope: !437, inlinedAt: !463)
!502 = !DILocation(line: 171, column: 26, scope: !437, inlinedAt: !463)
!503 = !{!481, !302, i64 32}
!504 = distinct !DIAssignID()
!505 = !DILocation(line: 172, column: 14, scope: !437, inlinedAt: !463)
!506 = !DILocation(line: 172, column: 26, scope: !437, inlinedAt: !463)
!507 = !{!481, !302, i64 36}
!508 = distinct !DIAssignID()
!509 = distinct !DIAssignID()
!510 = !DILocation(line: 0, scope: !451, inlinedAt: !463)
!511 = !DILocation(line: 175, column: 9, scope: !451, inlinedAt: !463)
!512 = !DILocation(line: 176, column: 30, scope: !513, inlinedAt: !463)
!513 = distinct !DILexicalBlock(scope: !514, file: !3, line: 175, column: 48)
!514 = distinct !DILexicalBlock(scope: !451, file: !3, line: 175, column: 9)
!515 = !DILocation(line: 179, column: 13, scope: !516, inlinedAt: !463)
!516 = distinct !DILexicalBlock(scope: !437, file: !3, line: 179, column: 13)
!517 = !DILocation(line: 179, column: 74, scope: !516, inlinedAt: !463)
!518 = !DILocation(line: 179, column: 13, scope: !437, inlinedAt: !463)
!519 = !DILocation(line: 189, column: 5, scope: !438, inlinedAt: !463)
!520 = !DILocation(line: 184, column: 14, scope: !437, inlinedAt: !463)
!521 = !DILocation(line: 185, column: 14, scope: !522, inlinedAt: !463)
!522 = distinct !DILexicalBlock(scope: !437, file: !3, line: 185, column: 13)
!523 = !DILocation(line: 213, column: 71, scope: !439, inlinedAt: !463)
!524 = !DILocation(line: 214, column: 71, scope: !439, inlinedAt: !463)
!525 = !DILocation(line: 192, column: 29, scope: !453, inlinedAt: !463)
!526 = !DILocation(line: 0, scope: !453, inlinedAt: !463)
!527 = !DILocation(line: 193, column: 35, scope: !453, inlinedAt: !463)
!528 = !DILocation(line: 193, column: 9, scope: !453, inlinedAt: !463)
!529 = !DILocation(line: 194, column: 35, scope: !453, inlinedAt: !463)
!530 = !DILocation(line: 194, column: 48, scope: !453, inlinedAt: !463)
!531 = !DILocation(line: 194, column: 9, scope: !453, inlinedAt: !463)
!532 = !DILocation(line: 196, column: 20, scope: !533, inlinedAt: !463)
!533 = distinct !DILexicalBlock(scope: !453, file: !3, line: 196, column: 13)
!534 = !DILocation(line: 196, column: 24, scope: !533, inlinedAt: !463)
!535 = !DILocation(line: 196, column: 40, scope: !533, inlinedAt: !463)
!536 = !DILocation(line: 196, column: 34, scope: !533, inlinedAt: !463)
!537 = !DILocation(line: 196, column: 13, scope: !453, inlinedAt: !463)
!538 = !DILocation(line: 197, column: 25, scope: !533, inlinedAt: !463)
!539 = !DILocation(line: 197, column: 13, scope: !533, inlinedAt: !463)
!540 = !DILocation(line: 199, column: 27, scope: !541, inlinedAt: !463)
!541 = distinct !DILexicalBlock(scope: !453, file: !3, line: 199, column: 13)
!542 = !DILocation(line: 199, column: 23, scope: !541, inlinedAt: !463)
!543 = !DILocation(line: 199, column: 21, scope: !541, inlinedAt: !463)
!544 = !DILocation(line: 199, column: 13, scope: !453, inlinedAt: !463)
!545 = !DILocation(line: 200, column: 29, scope: !541, inlinedAt: !463)
!546 = !DILocation(line: 200, column: 13, scope: !541, inlinedAt: !463)
!547 = !DILocation(line: 202, column: 27, scope: !548, inlinedAt: !463)
!548 = distinct !DILexicalBlock(scope: !453, file: !3, line: 202, column: 13)
!549 = !DILocation(line: 202, column: 23, scope: !548, inlinedAt: !463)
!550 = !DILocation(line: 202, column: 21, scope: !548, inlinedAt: !463)
!551 = !DILocation(line: 202, column: 13, scope: !453, inlinedAt: !463)
!552 = !DILocation(line: 203, column: 29, scope: !548, inlinedAt: !463)
!553 = !DILocation(line: 203, column: 13, scope: !548, inlinedAt: !463)
!554 = !DILocation(line: 206, column: 9, scope: !439, inlinedAt: !463)
!555 = !DILocation(line: 206, column: 19, scope: !439, inlinedAt: !463)
!556 = !DILocation(line: 209, column: 46, scope: !439, inlinedAt: !463)
!557 = !DILocation(line: 209, column: 40, scope: !439, inlinedAt: !463)
!558 = !DILocation(line: 209, column: 56, scope: !439, inlinedAt: !463)
!559 = !DILocalVariable(name: "value", arg: 1, scope: !560, file: !173, line: 88, type: !146)
!560 = distinct !DISubprogram(name: "fixed_from_uint", scope: !173, file: !173, line: 88, type: !561, scopeLine: 89, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !563)
!561 = !DISubroutineType(types: !562)
!562 = !{!184, !146}
!563 = !{!559}
!564 = !DILocation(line: 0, scope: !560, inlinedAt: !565)
!565 = distinct !DILocation(line: 210, column: 43, scope: !439, inlinedAt: !463)
!566 = !DILocation(line: 90, column: 18, scope: !560, inlinedAt: !565)
!567 = !DILocation(line: 210, column: 9, scope: !439, inlinedAt: !463)
!568 = !DILocation(line: 210, column: 41, scope: !439, inlinedAt: !463)
!569 = !{!482, !482, i64 0}
!570 = !DILocation(line: 211, column: 66, scope: !439, inlinedAt: !463)
!571 = !DILocation(line: 211, column: 62, scope: !439, inlinedAt: !463)
!572 = !DILocation(line: 0, scope: !560, inlinedAt: !573)
!573 = distinct !DILocation(line: 211, column: 46, scope: !439, inlinedAt: !463)
!574 = !DILocation(line: 90, column: 18, scope: !560, inlinedAt: !573)
!575 = !DILocation(line: 211, column: 5, scope: !439, inlinedAt: !463)
!576 = !DILocation(line: 211, column: 44, scope: !439, inlinedAt: !463)
!577 = !DILocation(line: 212, column: 76, scope: !439, inlinedAt: !463)
!578 = !DILocation(line: 212, column: 72, scope: !439, inlinedAt: !463)
!579 = !DILocation(line: 0, scope: !560, inlinedAt: !580)
!580 = distinct !DILocation(line: 212, column: 56, scope: !439, inlinedAt: !463)
!581 = !DILocation(line: 90, column: 18, scope: !560, inlinedAt: !580)
!582 = !DILocation(line: 212, column: 5, scope: !439, inlinedAt: !463)
!583 = !DILocation(line: 212, column: 54, scope: !439, inlinedAt: !463)
!584 = !DILocation(line: 213, column: 67, scope: !439, inlinedAt: !463)
!585 = !DILocation(line: 0, scope: !560, inlinedAt: !586)
!586 = distinct !DILocation(line: 213, column: 51, scope: !439, inlinedAt: !463)
!587 = !DILocation(line: 90, column: 18, scope: !560, inlinedAt: !586)
!588 = !DILocation(line: 213, column: 5, scope: !439, inlinedAt: !463)
!589 = !DILocation(line: 213, column: 49, scope: !439, inlinedAt: !463)
!590 = !DILocation(line: 214, column: 67, scope: !439, inlinedAt: !463)
!591 = !DILocation(line: 0, scope: !560, inlinedAt: !592)
!592 = distinct !DILocation(line: 214, column: 51, scope: !439, inlinedAt: !463)
!593 = !DILocation(line: 90, column: 18, scope: !560, inlinedAt: !592)
!594 = !DILocation(line: 214, column: 5, scope: !439, inlinedAt: !463)
!595 = !DILocation(line: 214, column: 49, scope: !439, inlinedAt: !463)
!596 = !DILocation(line: 215, column: 25, scope: !439, inlinedAt: !463)
!597 = !DILocation(line: 215, column: 33, scope: !439, inlinedAt: !463)
!598 = !DILocation(line: 215, column: 20, scope: !439, inlinedAt: !463)
!599 = !DILocation(line: 90, column: 18, scope: !560, inlinedAt: !600)
!600 = distinct !DILocation(line: 216, column: 41, scope: !439, inlinedAt: !463)
!601 = !DILocation(line: 0, scope: !560, inlinedAt: !600)
!602 = !DILocation(line: 216, column: 5, scope: !439, inlinedAt: !463)
!603 = !DILocation(line: 216, column: 39, scope: !439, inlinedAt: !463)
!604 = !DILocation(line: 219, column: 5, scope: !439, inlinedAt: !463)
!605 = !DILocation(line: 219, column: 11, scope: !439, inlinedAt: !463)
!606 = distinct !DIAssignID()
!607 = !DILocation(line: 220, column: 22, scope: !439, inlinedAt: !463)
!608 = !DILocation(line: 223, column: 9, scope: !461, inlinedAt: !463)
!609 = !DILocation(line: 223, column: 9, scope: !439, inlinedAt: !463)
!610 = !DILocalVariable(name: "dp", arg: 1, scope: !611, file: !3, line: 108, type: !211)
!611 = distinct !DISubprogram(name: "predict_dt", scope: !3, file: !3, line: 108, type: !612, scopeLine: 109, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !616)
!612 = !DISubroutineType(types: !613)
!613 = !{!160, !211, !614}
!614 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !615, size: 64)
!615 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !172)
!616 = !{!610, !617, !618, !619, !621, !626}
!617 = !DILocalVariable(name: "tree", arg: 2, scope: !611, file: !3, line: 108, type: !614)
!618 = !DILocalVariable(name: "node_idx", scope: !611, file: !3, line: 113, type: !84)
!619 = !DILocalVariable(name: "depth", scope: !620, file: !3, line: 116, type: !160)
!620 = distinct !DILexicalBlock(scope: !611, file: !3, line: 116, column: 5)
!621 = !DILocalVariable(name: "node", scope: !622, file: !3, line: 120, type: !624)
!622 = distinct !DILexicalBlock(scope: !623, file: !3, line: 116, column: 56)
!623 = distinct !DILexicalBlock(scope: !620, file: !3, line: 116, column: 5)
!624 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !625, size: 64)
!625 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !178)
!626 = !DILocalVariable(name: "raw_feat", scope: !622, file: !3, line: 132, type: !184)
!627 = !DILocation(line: 0, scope: !611, inlinedAt: !628)
!628 = distinct !DILocation(line: 224, column: 23, scope: !460, inlinedAt: !463)
!629 = !DILocation(line: 110, column: 24, scope: !630, inlinedAt: !628)
!630 = distinct !DILexicalBlock(scope: !611, file: !3, line: 110, column: 9)
!631 = !{!632, !302, i64 160000}
!632 = !{!"", !303, i64 0, !302, i64 160000, !303, i64 160008, !303, i64 160056}
!633 = !DILocation(line: 110, column: 34, scope: !630, inlinedAt: !628)
!634 = !DILocation(line: 110, column: 9, scope: !611, inlinedAt: !628)
!635 = !DILocation(line: 0, scope: !620, inlinedAt: !628)
!636 = !DILocation(line: 117, column: 22, scope: !637, inlinedAt: !628)
!637 = distinct !DILexicalBlock(scope: !622, file: !3, line: 117, column: 13)
!638 = !DILocation(line: 117, column: 41, scope: !637, inlinedAt: !628)
!639 = !DILocation(line: 120, column: 32, scope: !622, inlinedAt: !628)
!640 = !DILocation(line: 0, scope: !622, inlinedAt: !628)
!641 = !DILocation(line: 123, column: 19, scope: !642, inlinedAt: !628)
!642 = distinct !DILexicalBlock(scope: !622, file: !3, line: 123, column: 13)
!643 = !{!644, !302, i64 20}
!644 = !{!"", !302, i64 0, !302, i64 4, !482, i64 8, !302, i64 16, !302, i64 20, !302, i64 24}
!645 = !DILocation(line: 123, column: 13, scope: !642, inlinedAt: !628)
!646 = !DILocation(line: 123, column: 13, scope: !622, inlinedAt: !628)
!647 = !DILocation(line: 124, column: 26, scope: !648, inlinedAt: !628)
!648 = distinct !DILexicalBlock(scope: !642, file: !3, line: 123, column: 28)
!649 = !{!644, !302, i64 24}
!650 = !DILocation(line: 124, column: 13, scope: !648, inlinedAt: !628)
!651 = !DILocation(line: 128, column: 19, scope: !652, inlinedAt: !628)
!652 = distinct !DILexicalBlock(scope: !622, file: !3, line: 128, column: 13)
!653 = !{!644, !302, i64 16}
!654 = !DILocation(line: 128, column: 31, scope: !652, inlinedAt: !628)
!655 = !DILocation(line: 128, column: 35, scope: !652, inlinedAt: !628)
!656 = !DILocation(line: 132, column: 26, scope: !622, inlinedAt: !628)
!657 = !DILocation(line: 135, column: 31, scope: !658, inlinedAt: !628)
!658 = distinct !DILexicalBlock(scope: !622, file: !3, line: 135, column: 13)
!659 = !{!644, !482, i64 8}
!660 = !DILocation(line: 135, column: 22, scope: !658, inlinedAt: !628)
!661 = !DILocation(line: 135, column: 13, scope: !622, inlinedAt: !628)
!662 = !DILocation(line: 137, column: 23, scope: !663, inlinedAt: !628)
!663 = distinct !DILexicalBlock(scope: !664, file: !3, line: 137, column: 17)
!664 = distinct !DILexicalBlock(scope: !658, file: !3, line: 135, column: 44)
!665 = !{!644, !302, i64 0}
!666 = !DILocation(line: 137, column: 32, scope: !663, inlinedAt: !628)
!667 = !DILocation(line: 137, column: 36, scope: !663, inlinedAt: !628)
!668 = !DILocation(line: 142, column: 23, scope: !669, inlinedAt: !628)
!669 = distinct !DILexicalBlock(scope: !670, file: !3, line: 142, column: 17)
!670 = distinct !DILexicalBlock(scope: !658, file: !3, line: 140, column: 16)
!671 = !{!644, !302, i64 4}
!672 = !DILocation(line: 142, column: 33, scope: !669, inlinedAt: !628)
!673 = !DILocation(line: 142, column: 37, scope: !669, inlinedAt: !628)
!674 = !DILocation(line: 0, scope: !658, inlinedAt: !628)
!675 = !DILocation(line: 116, column: 52, scope: !623, inlinedAt: !628)
!676 = !DILocation(line: 116, column: 31, scope: !623, inlinedAt: !628)
!677 = !DILocation(line: 116, column: 5, scope: !620, inlinedAt: !628)
!678 = distinct !{!678, !677, !679, !680}
!679 = !DILocation(line: 146, column: 5, scope: !620, inlinedAt: !628)
!680 = !{!"llvm.loop.mustprogress"}
!681 = !DILocation(line: 0, scope: !461, inlinedAt: !463)
!682 = !{!481, !302, i64 88}
!683 = !DILocation(line: 232, column: 8, scope: !684, inlinedAt: !463)
!684 = distinct !DILexicalBlock(scope: !439, file: !3, line: 232, column: 8)
!685 = !DILocation(line: 237, column: 1, scope: !439, inlinedAt: !463)
!686 = !DILocation(line: 261, column: 10, scope: !267)
!687 = !DILocation(line: 262, column: 9, scope: !288)
!688 = !DILocation(line: 262, column: 9, scope: !267)
!689 = !DILocation(line: 263, column: 26, scope: !287)
!690 = !DILocation(line: 0, scope: !287)
!691 = !DILocation(line: 264, column: 41, scope: !287)
!692 = !{!693, !482, i64 0}
!693 = !{!"", !482, i64 0, !482, i64 8, !302, i64 16, !302, i64 20}
!694 = !DILocation(line: 264, column: 35, scope: !287)
!695 = !DILocation(line: 264, column: 13, scope: !287)
!696 = !DILocation(line: 264, column: 23, scope: !287)
!697 = !{!693, !482, i64 8}
!698 = !DILocation(line: 265, column: 13, scope: !287)
!699 = !DILocation(line: 265, column: 25, scope: !287)
!700 = !{!693, !302, i64 20}
!701 = !DILocation(line: 266, column: 13, scope: !287)
!702 = !DILocation(line: 266, column: 24, scope: !287)
!703 = !{!693, !302, i64 16}
!704 = !DILocation(line: 267, column: 9, scope: !287)
!705 = !DILocation(line: 268, column: 5, scope: !287)
!706 = !DILocation(line: 271, column: 1, scope: !267)
