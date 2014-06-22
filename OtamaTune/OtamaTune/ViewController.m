//
//  ViewController.m
//  OtamaTune
//
//  Created by Kouki Saito on 2014/06/19.
//  Copyright (c) 2014年 Kouki. All rights reserved.
//

#import "ViewController.h"

#import <Accelerate/Accelerate.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self execute];
}


- (void)execute
{
    int dataLength = 512;
    float* data = calloc(dataLength, sizeof(float));
    for(int i = 0; i < dataLength; i++) {
        // dataLength中で30回振動させる
        data[i] = sin(i * 30.0f / (float)dataLength * 2.0f * M_PI);
    }
    [self calcFFT:data dataLength:dataLength];
}


- (void)calcFFT:(float*)data dataLength:(int)length
{
    // データ長を2のn乗の大きさにする
    unsigned int sizeLog2 = (int)(log(length)/log(2));
    unsigned int size = 1 << sizeLog2;
    
    // fftのセットアップ
    FFTSetup fftSetUp = vDSP_create_fftsetup(sizeLog2 + 1, FFT_RADIX2);
    
    // 窓関数の用意
    float* window = calloc(size, sizeof(float));
    float* windowedInput = calloc(size, sizeof(float));
    vDSP_hann_window(window, size, 0);
    
    // 窓関数を入力値に適用し、windewedInputへ
    vDSP_vmul(data, 1, window, 1, windowedInput, 1, size);
    
    // 入力を複素数にする
    DSPSplitComplex splitComplex;
    splitComplex.realp = calloc(size, sizeof(float));
    splitComplex.imagp = calloc(size, sizeof(float));
    
    for (int i = 0; i < size; i++) {
        splitComplex.realp[i] = windowedInput[i];
        splitComplex.imagp[i] = 0.0f;
    }
    
    // FFTを計算する
    vDSP_fft_zrip(fftSetUp, &splitComplex, 1, sizeLog2 + 1, FFT_FORWARD);
    
    // 結果を表示する
    // FFTの性質から半分のデータのみ利用する
    for (int i = 0; i <= size/2; i++) {
        float real = splitComplex.realp[i];
        float imag = splitComplex.imagp[i];
        float distance = sqrt(real*real + imag*imag);
        NSLog(@"[%d] %.2f", i, distance);
    }
    
    // メモリを開放する
    free(splitComplex.realp);
    free(splitComplex.imagp);
    free(window);
    free(windowedInput);
    vDSP_destroy_fftsetup(fftSetUp);
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
