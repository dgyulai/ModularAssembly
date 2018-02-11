using System;
using Mosel;
using Microsoft.Office;
using Excel = Microsoft.Office.Interop.Excel;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Runtime.InteropServices;


namespace BenchmarkFramework
{
    class Program
    {
            public static void Main(string[] args)
            {

            int NumOfExperiments = 1;
            for (int i = 1; i <= NumOfExperiments; i++)
            {
                Console.WriteLine(i);
                RunMacro();
                RunXPRESS(i);
            }
            
            Console.ReadKey();
        }

        private static void RunMacro()
        {
            //~~> Define your Excel Objects
            Excel.Application xlApp = new Excel.Application();
            Excel.Workbook xlWorkBook;

            //~~> Start Excel and open the workbook.
            xlWorkBook = xlApp.Workbooks.Open("c:\\Adatok\\SZTAKI\\IJAMT\\Experiments\\benchmarkInput.xls");

            //~~> Run the macros by supplying the necessary arguments
            xlApp.Run("OrderCreation");

            //~~> Clean-up: Close the workbook
            xlWorkBook.Close(false);

            //~~> Quit the Excel Application
            xlApp.Quit();
        }

        private static void RunXPRESS(int RunNo)
        {
            XPRM mosel;
            XPRMModel mod;
            XPRMArray varr;
            XPRMMPVar x;
            XPRMSet shares;
            int[] indices;

            mosel = XPRM.Init();                        // Initialize Mosel

            mod = mosel.LoadModel("c:\\Adatok\\SZTAKI\\IJAMT\\Experiments\\benchmark_main.bim");     // Load compiled model

            mod.ExecParams = "RunIndex= " + RunNo;
            mod.Run();
            mod.Dispose();
        }
    }
}