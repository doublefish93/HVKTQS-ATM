using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Configuration;
using System.Data.SqlClient;

namespace ATMSystem
{
    public partial class DangNhap : Form
    {
        private static readonly string url = ConfigurationManager.ConnectionStrings["ATMSystem.Properties.Settings.ATMSYSTEMConnectionString"].ConnectionString;
        public DangNhap()
        {
            InitializeComponent();
        }

        private void button2_Click(object sender, EventArgs e)
        {

        }

        private void button1_Click(object sender, EventArgs e)
        {

        }

        private void button1_Click_1(object sender, EventArgs e)
        {

            
            if (string.IsNullOrEmpty(url))
            {
                MessageBox.Show("Kiểm tra lại đường dẫn kết nối");
                return;
            }
            var conn = new SqlConnection(url);
            try
            {
                if (string.IsNullOrEmpty(txtTK.Text))
                {
                    MessageBox.Show("Bạn chưa nhập tài khoản");
                    return;
                }

                if (string.IsNullOrEmpty(txtMK.Text))
                {
                    MessageBox.Show("Bạn chưa nhập mật khẩu");
                    return;
                }


                conn.Open();


                const string query = "Select * from Administrator where Admin_Username=@User and Admin_Password=@Pass";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@User", txtTK.Text);
                cmd.Parameters.AddWithValue("@Pass", txtMK.Text);

                SqlDataReader dr = cmd.ExecuteReader();

                var dt = new DataTable();

                dt.Load(dr);

                if (dt.Rows.Count <= 0)
                {
                    MessageBox.Show("Tài khoản hoặc mật khẩu của bạn không đúng!");
                    return;
                  
                }
                MessageBox.Show("Đăng nhập thành công");
                var admin = dt.Rows[0][1].ToString();
          
              
            }
            catch (Exception ex)
            {
                MessageBox.Show("Không thể kết nối tới máy chủ CSDL! Vui lòng kiểm tra lại.");
            }
            finally
            {
                conn.Close();
            }
        }
    }
}
