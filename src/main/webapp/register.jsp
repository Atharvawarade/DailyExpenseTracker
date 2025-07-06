<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>User Registration</title>
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

        .register-container {
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

        .register-form {
            flex: 1;
            background-color: #f8f9fa;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            z-index: 1;
        }

        .register-image {
            flex: 1;
            position: relative;
            overflow: hidden;
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
            .register-image {
                display: none;
            }
        }
    </style>
</head>
<body>
<div class="register-container">
    <div class="register-form">
        <div class="form-box">
            <h2 class="text-center">Register</h2>
            <form action="auth" method="post">
                <input type="hidden" name="action" value="register">

                <div class="mb-3">
                    <label for="name" class="form-label">Name</label>
                    <input type="text" class="form-control" id="name" name="name" required>
                </div>

                <div class="mb-3">
                    <label for="email" class="form-label">Email address</label>
                    <input type="email" class="form-control" id="email" name="email" required>
                </div>

                <div class="mb-4">
                    <label for="password" class="form-label">Password</label>
                    <input type="password" class="form-control" id="password" name="password" required>
                </div>

                <button type="submit" class="btn btn-primary">Register</button>
            </form>
            <div class="mt-3 text-center">
                <a href="login.jsp">Already have an account? Login</a>
            </div>
        </div>
    </div>
    <div class="register-image">
        <video autoplay muted loop class="bg-video">
            <source src="assets/Login_Bg_video.mp4" type="video/mp4">
        </video>
    </div>
</div>
</body>
</html>
