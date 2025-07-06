<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>User Login</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link rel="stylesheet" href="css/style.css">
    <style>
        body {
            margin: 0;
            height: 100vh;
            overflow: hidden;
            font-family: 'Segoe UI', sans-serif;
        }

        .login-container {
            display: flex;
            height: 100vh;
        }

        .bg-video {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
            z-index: -1;
        }


        .login-image {
            flex: 1;
            position: relative;
            overflow: hidden;
        }

        .login-form {
            flex: 1;
            background-color: #f8f9fa;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .form-box {
            width: 80%;
            padding: 30px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 0 15px rgba(0,0,0,0.1);
        }

        .form-box h2 {
            margin-bottom: 20px;
            font-weight: 600;
            color: #343a40;
        }

        .form-control {
            border-radius: 8px;
        }

        .btn-primary {
            width: 100%;
            border-radius: 8px;
        }

        .form-box a {
            text-decoration: none;
            color: #007bff;
            font-size: 0.9rem;
        }

        @media (max-width: 768px) {
            .login-image {
                display: none;
            }
        }
    </style>
</head>
<body>
<div class="login-container">
    <div class="login-image">
        <video autoplay muted loop class="bg-video">
            <source src="assets/Login_Bg_video.mp4" type="video/mp4">
        </video>
    </div>
    <div class="login-form">
        <div class="form-box">
            <h2 class="text-center">Login</h2>
            <form action="auth" method="post">
                <input type="hidden" name="action" value="login">

                <div class="mb-3">
                    <label for="email" class="form-label">Email address</label>
                    <input type="email" class="form-control" id="email" name="email" required>
                </div>

                <div class="mb-4">
                    <label for="password" class="form-label">Password</label>
                    <input type="password" class="form-control" id="password" name="password" required>
                </div>

                <button type="submit" class="btn btn-primary">Login</button>
            </form>
            <div class="mt-3 text-center">
                <a href="register.jsp">New user? Register here</a>
            </div>
        </div>
    </div>
</div>
</body>
</html>
