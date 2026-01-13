package com.backend.service;

import com.backend.dto.request.UserPostRequest;
import com.backend.exception.MailWithUserAlreadyExistsException;
import com.backend.model.User;
import com.backend.repository.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public void saveUser(UserPostRequest userPostRequest) {
        Optional<User> user = userRepository.findByEmail(userPostRequest.getEmail());

        if (user.isPresent()) {
            throw new MailWithUserAlreadyExistsException("User with this email already exists");
        }

        userRepository.save(new User(userPostRequest.getUsername(),
                passwordEncoder.encode(userPostRequest.getPassword()),
                userPostRequest.getEmail(), userPostRequest.getName(),
                userPostRequest.getSurname(),
                userPostRequest.getRole()));
    }

    public void changePassword(long id, String newPassword) {
        User user = userRepository.findById(id).orElseThrow(() -> new EntityNotFoundException("User not found!"));
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
    }

    protected User findUserByEmail(String email) {
        return userRepository.findByEmail(email).orElseThrow(() -> new EntityNotFoundException("User not found!"));
    }

    protected void updateUser(User user) {
        userRepository.save(user);
    }

    public boolean userExistsByEmail(String email) {
        return userRepository.findByEmail(email).isPresent();
    }
}
