package com.example.guestbook;

import com.example.guestbook.entity.Greeting;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class GuestbookControllerServlet extends HttpServlet
{

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException
    {
        doPost(req, resp);
    }

    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException
    {
        // On détermine quel guestbook utiliser
        String guestbookName = request.getParameter("guestbookName");
        if (guestbookName == null)
        {
            guestbookName = "default";
        }
        // On transmet cette information à la vue
        request.setAttribute("guestbookName", guestbookName);

        // Service d'authentification Google
        UserService userService = UserServiceFactory.getUserService();
        User user = userService.getCurrentUser();
        request.setAttribute("user", user);

        String logoutURL = userService.createLogoutURL(request.getRequestURI());
        String loginURL = userService.createLoginURL(request.getRequestURI());
        // On transmet à la vue les URL de lgin et logout
        request.setAttribute("logoutURL", logoutURL);
        request.setAttribute("loginURL", loginURL);

        GuestBookDAO dao = new GuestBookDAO();
        try
        {
            // On détermine l'action qui a provoqué l'appel de la servlet
            // Cf. formulaires de saisie dans la vue
            String action = request.getParameter("action");
            if ("addGreeting".equals(action))
            {
                // Si nécessaire, on ajoute un Greeting
                String content = request.getParameter("content");
                String authorId = (user == null) ? "Unknown author" : user.getUserId();
                String authorEmail = (user == null) ? "Unknown email" : user.getEmail();
                dao.addGreeting(guestbookName, authorId, authorEmail, content);

            }
            // On utilise le DAO pour trouver les données nécessaires à la vue
            List<Greeting> greetings = dao.findGreetingsIn(guestbookName);
            List<String> books = dao.existingBooks();
            // On transmet ces informations à la vue
            request.setAttribute("books", books);
            request.setAttribute("greetings", greetings);
            request.setAttribute("statistics", dao.getStats());
        }
        catch (SQLException | ServletException ex)
        {
            Logger.getLogger(GuestbookControllerServlet.class.getName()).log(Level.SEVERE, null, ex);
        }
        request.getRequestDispatcher("guestbookView.jsp").forward(request, response);
    }
}
